# frozen_string_literal: true

class HistoryItem < ApplicationRecord
  include CleanupAndConvertTaxtColumns
  include Trackable

  TYPE_ATTRIBUTES = [
    :taxt, :subtype,
    :picked_value, :text_value,
    :object_protonym, :object_taxon,
    :reference, :pages,
    :force_author_citation
  ]
  OPTIONAL_TYPE_ATTRIBUTES = [:force_author_citation]

  # TODO: Remove temporary refactor helper once done.
  History::Definitions::TYPES.each do |type|
    HistoryItem.const_set(type.underscore.upcase, type)
  end
  TYPE_DEFINITIONS = History::Definitions::TYPE_DEFINITIONS
  TYPES = History::Definitions::TYPES
  LECTOTYPE_DESIGNATION = History::Definitions::LECTOTYPE_DESIGNATION
  NEOTYPE_DESIGNATION = History::Definitions::NEOTYPE_DESIGNATION

  self.inheritance_column = :_type_column_disabled

  alias_attribute :current_taxon_owner, :terminal_taxon

  delegate :groupable?, to: :definition

  belongs_to :protonym
  belongs_to :reference, optional: true
  belongs_to :object_protonym, optional: true, class_name: 'Protonym'
  belongs_to :object_taxon, optional: true, class_name: 'Taxon'

  has_one :terminal_taxon, through: :protonym
  has_many :terminal_taxa, through: :protonym

  validates :rank, inclusion: { in: Rank::AntCatSpecific::TYPE_SPECIFIC_HISTORY_ITEM_TYPES, allow_nil: true }
  validates :type, inclusion: { in: TYPES }
  validate :validate_type_specific_attributes
  with_options if: :relational? do
    validate :validate_subtype
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
    return true if relational?
    Taxt::StandardHistoryItemFormats.new(taxt).standard?
  end

  def taxt_type?
    type == TAXT
  end

  def relational?
    !taxt_type?
  end

  def to_taxt
    return taxt if taxt_type?

    if groupable?
      item_template_to_taxt grouped_item_taxts: groupable_item_template_to_taxt
    else
      item_template_to_taxt
    end
  end

  def item_template_to_taxt vars = {}
    return taxt if taxt_type?

    item_template % item_template_vars.merge(vars)
  end

  def groupable_item_template_to_taxt
    groupable_item_template % groupable_item_template_vars
  end

  def citation_taxt
    raise 'not supported' if taxt_type?
    return unless reference_id || pages

    "#{Taxt.to_ref_tag(reference_id || 'REFERENCE_ID MISSING')}: #{pages || 'PAGES_MISSING'}"
  end
  alias_method :citation, :citation_taxt

  def group_key
    return @_group_key if defined?(@_group_key)

    @_group_key ||= if (key = definitions.fetch(:group_key, nil))
                      key.call(self)
                    else
                      id
                    end
  end

  def ids_from_taxon_tags
    Taxt.extract_ids_from_taxon_tags(taxt)
  end

  def type_label
    definitions.fetch(:type_label)
  end

  def underscored_type
    type.underscore
  end

  def definitions
    @_definitions ||= TYPE_DEFINITIONS[type]
  end

  def definition
    @_definition ||= History::Definition.new(definitions)
  end

  private

    def item_template
      definitions.fetch(:item_template)
    end

    def item_template_vars
      return {} unless (vars = definitions[:item_template_vars])
      vars.call(self).symbolize_keys
    end

    def groupable_item_template
      @_groupable_item_template ||= definitions.fetch(:groupable_item_template, nil)
    end

    def groupable_item_template_vars
      return {} unless (vars = definitions[:groupable_item_template_vars])
      vars.call(self).symbolize_keys
    end

    def cleanup_and_convert_taxts
      cleanup_and_convert_taxt_columns :taxt
    end

    def validate_type_specific_attributes
      return unless type.in?(TYPES)

      required_presence = definitions.fetch(:validates_presence_of)
      required_absence = TYPE_ATTRIBUTES - required_presence - optional_attributes - OPTIONAL_TYPE_ATTRIBUTES

      validates_presence_of(required_presence) if required_presence.present?
      validates_absence_of(required_absence) if required_absence.present?
    end

    def optional_attributes
      @_optional_attributes ||= definitions[:optional_attributes] || []
    end

    def validate_subtype
      return unless (subtypes = definitions[:subtypes])
      validates_inclusion_of :subtype, in: subtypes
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
