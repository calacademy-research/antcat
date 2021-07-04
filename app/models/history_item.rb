# frozen_string_literal: true

class HistoryItem < ApplicationRecord
  include CleanupAndConvertTaxtColumns
  include Trackable

  TYPES = History::Definitions::TYPES
  TYPE_ATTRIBUTES = [
    :taxt, :subtype,
    :picked_value, :text_value,
    :object_protonym, :object_taxon,
    :reference, :pages,
    :force_author_citation
  ]
  OPTIONAL_TYPE_ATTRIBUTES = [:force_author_citation]

  PAGES_MAX_LENGTH = 50
  VALID_PAGES_REGEX = /\A[^;<>{}]*\z/ # Allow any format except weird characters for now.

  TEXT_VALUE_MAX_LENGTH = 50
  VALID_TEXT_VALUE_REGEX = /\A[^;<>{}]*\z/ # Allow any format except weird characters for now.

  self.inheritance_column = :_type_column_disabled

  delegate :groupable?, :type_label, to: :definition

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
    validates :pages,
      length: { maximum: PAGES_MAX_LENGTH },
      format: { with: VALID_PAGES_REGEX, allow_nil: true, message: "cannot contain: ; < > { }" }
    validates :text_value,
      length: { maximum: TEXT_VALUE_MAX_LENGTH },
      format: { with: VALID_TEXT_VALUE_REGEX, allow_nil: true, message: "cannot contain: ; < > { }" }

    validate :validate_subtype
    validate :validate_optional_reference_and_pages
    validate :validate_object_protonym_not_same_as_protonym
  end

  before_validation :cleanup_and_convert_taxts

  scope :persisted, -> { where.not(id: nil) }
  scope :unranked_and_for_rank, ->(type) { where(rank: [nil, type]) }

  scope :relational, -> { where.not(type: History::Definitions::TAXT) }
  scope :taxts_only, -> { where(type: History::Definitions::TAXT) }

  # Type scopes (the "_relitems" suffixes were added to make greping easier).
  scope :combination_in_relitems, -> { where(type: History::Definitions::COMBINATION_IN) }
  scope :form_descriptions_relitems, -> { where(type: History::Definitions::FORM_DESCRIPTIONS) }
  scope :senior_synonym_of_relitems, -> { where(type: History::Definitions::SENIOR_SYNONYM_OF) }
  scope :junior_synonym_of_relitems, -> { where(type: History::Definitions::JUNIOR_SYNONYM_OF) }
  scope :subspecies_of_relitems, -> { where(type: History::Definitions::SUBSPECIES_OF) }

  acts_as_list scope: :protonym, touch_on_update: false
  has_paper_trail
  strip_attributes only: [:taxt, :rank, :subtype, :picked_value, :text_value, :pages],
    replace_newlines: true
  trackable parameters: proc { { protonym_id: protonym_id } }

  def standard_format?
    return true if relational?
    Taxt::StandardHistoryItemFormats.new(taxt).standard?
  end

  def taxt_type?
    type == History::Definitions::TAXT
  end

  def relational?
    !taxt_type?
  end

  def to_taxt template_name = :default
    return taxt if taxt_type?

    if groupable?
      item_template_to_taxt template_name, grouped_item_taxts: groupable_template_to_taxt
    else
      item_template_to_taxt template_name
    end
  end

  def item_template_to_taxt template_name, vars = {}
    return taxt if taxt_type?

    definition.render_template(template_name, self, vars)
  end

  def groupable_template_to_taxt
    groupable_template_content % groupable_template_vars(self)
  end

  def citation_taxt
    raise 'not supported' if taxt_type?
    return unless reference_id || pages

    "#{Taxt.to_ref_tag(reference_id || 'REFERENCE_ID MISSING')}: #{pages || 'PAGES_MISSING'}"
  end
  alias_method :citation, :citation_taxt

  def group_key
    definition.group_key(self)
  end

  def ids_from_taxon_tags
    Taxt.extract_ids_from_taxon_tags(taxt)
  end

  def underscored_type
    type.underscore
  end

  def definition
    @_definition ||= History::Definition.from_type(type)
  end

  private

    delegate :groupable_template_content, :groupable_template_vars,
      :optional_attributes, to: :definition, private: true

    def cleanup_and_convert_taxts
      cleanup_and_convert_taxt_columns :taxt
    end

    def validate_type_specific_attributes
      return unless type.in?(TYPES)

      required_presence = definition.validates_presence_of
      required_absence = TYPE_ATTRIBUTES - required_presence - optional_attributes - OPTIONAL_TYPE_ATTRIBUTES

      validates_presence_of(required_presence) if required_presence.present?
      validates_absence_of(required_absence) if required_absence.present?
    end

    def validate_subtype
      return unless (subtypes = definition.subtypes)
      validates_inclusion_of :subtype, in: subtypes
    end

    def validate_object_protonym_not_same_as_protonym
      return if object_protonym_id != protonym_id
      errors.add :object_protonym, "cannot be the same as the history item's protonym"
    end

    def validate_optional_reference_and_pages
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
