# frozen_string_literal: true

class HistoryItem < ApplicationRecord
  include CleanupAndConvertTaxtColumns
  include Trackable

  TYPE_ATTRIBUTES = [
    :taxt, :subtype, :picked_value, :text_value, :object_protonym, :reference, :pages
  ]
  # [grep:history_type].
  TYPE_DEFINITIONS = {
    TAXT = 'Taxt' => {
      type_label: 'Taxt (freeform text)',
      type_as_label: 'Taxt (freeform text) for {pro %<protonym_id>i}',

      section_order: 999,
      section_group_key: ->(o) { [o.type, o.id] },

      group_template: '%<item_taxts>s',

      validates_presence_of: [:taxt]
    },
    FORM_DESCRIPTIONS = 'FormDescriptions' => {
      type_label: 'Form descriptions (additional)',
      type_as_label: 'Form descriptions (additional) for {pro %<protonym_id>i}',

      section_order: 1,
      section_group_key: ->(o) { o.type },

      group_template: '%<item_taxts>s.',

      item_template: '%<citation>s (%<forms>s)',
      item_template_vars: ->(o) { { citation: o.citation, forms: o.text_value } },

      validates_presence_of: [:text_value, :reference, :pages]
    },
    TYPE_SPECIMEN_DESIGNATION = 'TypeSpecimenDesignation' => {
      type_label: 'Type specimen designation',
      type_as_label: 'Type specimen designation for {pro %<protonym_id>i}',

      section_order: 2,
      section_group_key: ->(o) { [o.type, o.id] },

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
    JUNIOR_SYNONYM = 'JuniorSynonym' => {
      type_label: 'Junior synonym of',
      type_as_label: '{pro %<protonym_id>i} as junior synonym of ...',

      section_order: 6,
      section_group_key: ->(o) { [o.type, 'pro:', o.object_protonym_id] },

      group_template: 'Junior synonym of {prott %<object_protonym_id>i}: %<item_taxts>s.',
      group_template_vars: ->(o) { o.slice(:object_protonym_id) },

      item_template: '%<citation>s',
      item_template_vars: ->(o) { { citation: o.citation } },

      validates_presence_of: [:object_protonym, :reference, :pages]
    },
    SENIOR_SYNONYM = 'SeniorSynonym' => {
      type_label: 'Senior synonym of',
      type_as_label: '{pro %<protonym_id>i} as senior synonym of ...',

      section_order: 5,
      section_group_key: ->(o) { [o.type, 'pro:', o.object_protonym_id] },

      group_template: 'Senior synonym of {prott %<object_protonym_id>i}: %<item_taxts>s.',
      group_template_vars: ->(o) { o.slice(:object_protonym_id) },

      item_template: '%<citation>s',
      item_template_vars: ->(o) { { citation: o.citation } },

      validates_presence_of: [:object_protonym, :reference, :pages]
    }
  }
  TYPES = TYPE_DEFINITIONS.keys

  self.inheritance_column = :_type_column_disabled

  alias_attribute :current_taxon_owner, :terminal_taxon

  belongs_to :protonym
  belongs_to :reference, optional: true
  belongs_to :object_protonym, optional: true, class_name: 'Protonym'

  has_one :terminal_taxon, through: :protonym
  has_many :terminal_taxa, through: :protonym

  validates :rank, inclusion: { in: Rank::AntCatSpecific::TYPE_SPECIFIC_HISTORY_ITEM_TYPES, allow_nil: true }
  validates :type, inclusion: { in: TYPES }
  validate :validate_type_specific_attributes

  before_validation :cleanup_and_convert_taxts

  scope :persisted, -> { where.not(id: nil) }
  scope :unranked_and_for_rank, ->(type) { where(rank: [nil, type]) }
  scope :except_taxts, -> { where.not(type: TAXT) }
  scope :taxts_only, -> { where(type: TAXT) }

  acts_as_list scope: :protonym
  has_paper_trail
  strip_attributes only: [:taxt, :rank, :subtype, :picked_value, :text_value],
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
    raise 'not supported' unless reference_id && pages
    "#{Taxt.to_ref_tag(reference_id)}: #{pages}"
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

  def type_label_to_taxt
    definitions.fetch(:type_as_label) % attributes.slice('protonym_id').symbolize_keys
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
      required_absence = TYPE_ATTRIBUTES - required_presence

      validates_presence_of required_presence
      validates_absence_of required_absence
    end
end
