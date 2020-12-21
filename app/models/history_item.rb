# frozen_string_literal: true

class HistoryItem < ApplicationRecord
  include CleanupAndConvertTaxtColumns
  include Trackable

  TYPE_ATTRIBUTES = [
    :taxt, :subtype,
    :picked_value, :text_value,
    :object_protonym, :object_taxon,
    :reference, :pages
  ]
  RANK_LABELS = [
    ANY_RANK_GROUP_LABEL = 'Any/all rank (-groups)',
    FAMILY_GROUP_LABEL = 'Family-group',
    GENUS_GROUP_LABEL = 'Genus-group',
    SPECIES_GROUP_LABEL = 'Species-group'
  ]
  # [grep:history_type].
  # TODO: Extract into new class now that we have a bunch.
  TYPE_DEFINITIONS = {
    TAXT = 'Taxt' => {
      type_label: 'Taxt (freeform text)',
      ranks: ANY_RANK_GROUP_LABEL,

      group_order: 999,
      group_key: ->(o) { o.id },

      group_template: '%<item_taxts>s',

      validates_presence_of: [:taxt]
    },
    TYPE_SPECIMEN_DESIGNATION = 'TypeSpecimenDesignation' => {
      type_label: 'Type specimen designation',
      ranks: SPECIES_GROUP_LABEL,

      group_order: 10,
      group_key: ->(o) { o.id },

      group_template: '%<designation_type>s: %<item_taxts>s.',
      group_template_vars: ->(o) { { designation_type: o.underscored_subtype.humanize } },

      item_template: '%<citation>s',
      item_template_vars: ->(o) { { citation: o.citation } },

      subtypes: [
        LECTOTYPE_DESIGNATION = 'LectotypeDesignation',
        NEOTYPE_DESIGNATION = 'NeotypeDesignation'
      ],
      subtype_options: [
        ['Lectotype designation', LECTOTYPE_DESIGNATION],
        ['Neotype designation', NEOTYPE_DESIGNATION]
      ],

      validates_presence_of: [:subtype, :reference, :pages]
    },
    FORM_DESCRIPTIONS = 'FormDescriptions' => {
      type_label: 'Form descriptions (additional)',
      ranks: SPECIES_GROUP_LABEL,

      group_order: 20,
      group_key: ->(o) { o.type },

      group_template: '%<item_taxts>s.',

      item_template: '%<citation>s (%<forms>s)',
      item_template_vars: ->(o) { { citation: o.citation, forms: o.text_value } },

      validates_presence_of: [:text_value, :reference, :pages]
    },
    COMBINATION_IN = 'CombinationIn' => {
      type_label: 'Combination in',
      ranks: SPECIES_GROUP_LABEL,

      group_order: 30,
      group_key: ->(o) { [o.type, 'object_taxon_id', o.object_taxon_id] },

      group_template: 'Combination in {tax %<object_taxon_id>i}: %<item_taxts>s.',
      group_template_vars: ->(o) { o.slice(:object_taxon_id) },

      item_template: '%<citation>s',
      item_template_vars: ->(o) { { citation: o.citation } },

      validates_presence_of: [:object_taxon, :reference, :pages]
    },
    JUNIOR_SYNONYM_OF = 'JuniorSynonymOf' => {
      type_label: 'Junior synonym of',
      ranks: ANY_RANK_GROUP_LABEL,

      group_order: 40,
      group_key: ->(o) { [o.type, 'object_protonym_id', o.object_protonym_id] },

      group_template: 'Junior synonym of {prott %<object_protonym_id>i}: %<item_taxts>s.',
      group_template_vars: ->(o) { o.slice(:object_protonym_id) },

      item_template: '%<citation>s',
      item_template_vars: ->(o) { { citation: o.citation } },

      validates_presence_of: [:object_protonym, :reference, :pages]
    },
    SENIOR_SYNONYM_OF = 'SeniorSynonymOf' => {
      type_label: 'Senior synonym of',
      ranks: ANY_RANK_GROUP_LABEL,

      group_order: 45,
      group_key: ->(o) { [o.type, 'object_protonym_id', o.object_protonym_id] },

      group_template: 'Senior synonym of {prott %<object_protonym_id>i}: %<item_taxts>s.',
      group_template_vars: ->(o) { o.slice(:object_protonym_id) },

      item_template: '%<citation>s',
      item_template_vars: ->(o) { { citation: o.citation } },

      validates_presence_of: [:object_protonym, :reference, :pages]
    },
    STATUS_AS_SPECIES = 'StatusAsSpecies' => {
      type_label: 'Status as species',
      ranks: SPECIES_GROUP_LABEL,

      group_order: 0,
      group_key: ->(o) { [o.type, 'object_protonym_id', o.object_protonym_id] },

      group_template: 'Status as species: %<item_taxts>s.',

      item_template: '%<citation>s',
      item_template_vars: ->(o) { { citation: o.citation } },

      validates_presence_of: [:reference, :pages]
    },
    SUBSPECIES_OF = 'SubspeciesOf' => {
      type_label: 'Subspecies of',
      ranks: SPECIES_GROUP_LABEL,

      group_order: 60,
      group_key: ->(o) { [o.type, 'object_taxon_id', o.object_taxon_id] },

      group_template: 'Subspecies of {tax %<object_taxon_id>i}: %<item_taxts>s.',
      group_template_vars: ->(o) { o.slice(:object_taxon_id) },

      item_template: '%<citation>s',
      item_template_vars: ->(o) { { citation: o.citation } },

      validates_presence_of: [:object_taxon, :reference, :pages]
    }
  }
  TYPES = TYPE_DEFINITIONS.keys

  self.inheritance_column = :_type_column_disabled

  alias_attribute :current_taxon_owner, :terminal_taxon

  belongs_to :protonym
  belongs_to :reference, optional: true
  belongs_to :object_protonym, optional: true, class_name: 'Protonym'
  belongs_to :object_taxon, optional: true, class_name: 'Taxon'

  has_one :terminal_taxon, through: :protonym
  has_many :terminal_taxa, through: :protonym

  validates :rank, inclusion: { in: Rank::AntCatSpecific::TYPE_SPECIFIC_HISTORY_ITEM_TYPES, allow_nil: true }
  validates :type, inclusion: { in: TYPES }
  validate :validate_type_specific_attributes
  with_options if: :hybrid? do
    validate :validate_reference_and_pages
  end

  before_validation :cleanup_and_convert_taxts

  scope :persisted, -> { where.not(id: nil) }
  scope :unranked_and_for_rank, ->(type) { where(rank: [nil, type]) }
  scope :except_taxts, -> { where.not(type: TAXT) }
  scope :taxts_only, -> { where(type: TAXT) }

  acts_as_list scope: :protonym
  has_paper_trail
  strip_attributes only: [:taxt, :rank, :subtype, :picked_value, :text_value, :pages],
    replace_newlines: true
  trackable parameters: proc { { protonym_id: protonym_id } }

  def standard_format?
    return true if hybrid?
    Taxt::StandardHistoryItemFormats.new(taxt).standard?
  end

  def taxt_type?
    type == TAXT
  end

  def hybrid?
    !taxt_type?
  end

  def to_taxt
    return taxt if taxt_type?
    section_to_taxt(groupable_item_taxt)
  end

  def section_to_taxt item_taxts
    group_template % group_template_vars.merge(item_taxts: item_taxts)
  end

  def groupable_item_taxt
    return taxt if taxt_type?
    item_template % item_template_vars
  end

  def citation_taxt
    raise 'not supported' if taxt_type?
    return unless reference_id || pages

    "#{Taxt.to_ref_tag(reference_id || 'REFERENCE_ID MISSING')}: #{pages || 'PAGES_MISSING'}"
  end
  alias_method :citation, :citation_taxt

  def object_protonym_prott_tag
    "{prott #{object_protonym_id}}"
  end

  def ids_from_tax_or_taxac_tags
    Taxt.extract_ids_from_tax_or_taxac_tags taxt
  end

  def type_label
    definitions.fetch(:type_label)
  end

  def underscored_type
    type.underscore
  end

  def underscored_subtype
    subtype.underscore
  end

  def definitions
    @_definitions ||= TYPE_DEFINITIONS[type]
  end

  private

    def group_template
      definitions.fetch(:group_template)
    end

    def group_template_vars
      return {} unless (vars = definitions[:group_template_vars])
      vars.call(self).symbolize_keys
    end

    def item_template
      definitions.fetch(:item_template)
    end

    def item_template_vars
      return {} unless (vars = definitions[:item_template_vars])
      vars.call(self).symbolize_keys
    end

    def cleanup_and_convert_taxts
      cleanup_and_convert_taxt_columns :taxt
    end

    def validate_type_specific_attributes
      return unless type.in?(TYPES)

      required_presence = definitions.fetch(:validates_presence_of)
      required_absence = TYPE_ATTRIBUTES - required_presence - optional_attributes

      validates_presence_of(required_presence) if required_presence.present?
      validates_absence_of(required_absence) if required_absence.present?
    end

    def optional_attributes
      @_optional_attributes ||= definitions[:optional_attributes] || []
    end

    def validate_reference_and_pages
      return unless optional_attributes.include?(:reference) || optional_attributes.include?(:pages)
      return if reference_and_pages_both_blank_or_present?

      errors.add :base, "Reference and pages can't be blank if one of them is not"
    end

    def reference_and_pages_both_blank_or_present?
      return true if reference && pages
      return true if !reference && !pages
      false
    end
end
