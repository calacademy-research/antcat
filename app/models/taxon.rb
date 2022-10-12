# frozen_string_literal: true

class Taxon < ApplicationRecord
  include Trackable

  TAXA_COLUMNS = [
    :family_id,
    :subfamily_id,
    :tribe_id,
    :genus_id,
    :subgenus_id,
    :species_id,
    :subspecies_id
  ]

  with_options class_name: 'Taxon' do
    belongs_to :homonym_replaced_by, optional: true
    belongs_to :current_taxon, optional: true

    has_many :replacement_name_for, foreign_key: :homonym_replaced_by_id, dependent: :restrict_with_error
    has_many :current_taxon_of, foreign_key: :current_taxon_id, dependent: :restrict_with_error
    has_many :junior_synonyms, -> { synonyms }, foreign_key: :current_taxon_id
    has_many :obsolete_combinations, -> { obsolete_combinations }, foreign_key: :current_taxon_id
  end

  belongs_to :name, dependent: :destroy
  belongs_to :protonym

  with_options inverse_of: :taxon, dependent: :destroy do
    has_many :reference_sections, -> { order(:position) }
  end

  has_one :authorship, through: :protonym
  has_one :authorship_reference, through: :authorship, source: :reference
  has_many :type_names, dependent: :restrict_with_error
  has_many :protonym_history_items, through: :protonym, source: :history_items
  has_many :history_items_for_taxon_including_hidden, ->(taxon) { unranked_and_for_rank(taxon.type) },
    through: :protonym, source: :history_items
  has_many :history_items_as_object_for_taxon_including_hidden,
    ->(taxon) { visible_as_object.unranked_and_for_rank(taxon.type) },
    through: :protonym, source: :history_items_as_object

  validates :status, inclusion: { in: Status::STATUSES }
  validates :incertae_sedis_in, inclusion: { in: Rank::INCERTAE_SEDIS_IN_TYPES, allow_nil: true }
  validates :homonym_replaced_by, absence: { message: "can't be set for non-homonyms" }, unless: -> { homonym? }
  validates :homonym_replaced_by, presence: { message: "must be set for homonyms" }, if: -> { homonym? }
  validates :unresolved_homonym, absence: { message: "can't be set for homonyms" }, if: -> { homonym? }
  validates :collective_group_name, absence: { message: "can only be set for fossil taxa" },
    unless: -> { protonym&.fossil? }
  validate :current_taxon_validation, :ensure_correct_name_type

  before_save :set_name_cache

  scope :valid, -> { where(status: Status::VALID) }
  scope :invalid, -> { where.not(status: Status::VALID) }
  scope :extant, -> { joins(:protonym).where(protonyms: { fossil: false }) }
  scope :fossil, -> { joins(:protonym).where(protonyms: { fossil: true }) }
  scope :homonyms, -> { where(status: Status::HOMONYM) }
  scope :obsolete_combinations, -> { where(status: Status::OBSOLETE_COMBINATION) }
  scope :original_combinations, -> { where(original_combination: true) }
  scope :synonyms, -> { where(status: Status::SYNONYM) }
  scope :replaced_homonyms, -> { where.not(homonym_replaced_by_id: nil) }

  scope :family_group_names, -> { where(type: Rank::FAMILY_GROUP_NAMES) }
  scope :genus_group_names, -> { where(type: Rank::GENUS_GROUP_NAMES) }
  scope :species_group_names, -> { where(type: Rank::SPECIES_GROUP_NAMES) }

  scope :order_by_name, -> { order(:name_cache) }

  accepts_nested_attributes_for :name, update_only: true
  has_paper_trail
  strip_attributes only: [:incertae_sedis_in], replace_newlines: true
  trackable parameters: proc {
    { rank: rank, name: name.name_html }.tap do |hsh|
      if parent
        hsh[:parent] = { rank: parent.rank, name: parent.name.name_html, id: parent.id }
      end
    end
  }

  searchable do
    string :type
    text :name_cache
    text(:authors) { authorship_reference.key.authors_for_key }
    text(:year_as_string) { authorship_reference.year.to_s }
  end

  [
    Status::SYNONYM,
    Status::HOMONYM,
    Status::UNIDENTIFIABLE,
    Status::UNAVAILABLE,
    Status::EXCLUDED_FROM_FORMICIDAE
  ].each do |status|
    define_method "#{status.downcase.tr(' ', '_')}?" do
      self.status == status
    end
  end

  def valid_status?
    status == Status::VALID
  end

  def rank
    type.downcase
  end

  def name_class
    "#{type}Name".constantize
  end

  def name_with_fossil
    name.name_with_fossil_html protonym.fossil?
  end

  def author_citation
    citation = authorship_reference.key_with_year
    return citation unless is_a?(SpeciesGroupTaxon) && recombination?

    '('.html_safe + citation + ')'
  end

  # TODO: Experimental.
  def now_taxon
    return self unless current_taxon
    current_taxon.now_taxon
  end

  # TODO: Experimental. We may want to stop doing this. Used for expanding type taxa (see `TypeNameDecorator`).
  def most_recent_before_now_taxon
    taxa = []
    iteratred_current_taxon = current_taxon

    while iteratred_current_taxon
      taxa << iteratred_current_taxon
      iteratred_current_taxon = iteratred_current_taxon.current_taxon
    end

    taxa.second_to_last || self
  end

  def history_items_for_taxon
    return HistoryItem.none unless Status.display_history_items?(status)
    history_items_for_taxon_including_hidden
  end

  def history_items_as_object_for_taxon
    return HistoryItem.none unless Status.display_history_items?(status)
    history_items_as_object_for_taxon_including_hidden
  end

  def policy
    @_policy ||= TaxonPolicy.new(self)
  end

  def soft_validations
    @_soft_validations ||= DbScriptSoftValidations.new(self, DbScriptSoftValidations::TAXA_DATABASE_SCRIPTS_TO_CHECK)
  end

  def what_links_here
    @_what_links_here ||= Taxa::WhatLinksHere.new(self)
  end

  private

    def set_name_cache
      self.name_cache = name.name
    end

    def current_taxon_validation
      if Status.cannot_have_current_taxon?(status) && current_taxon
        errors.add :current_taxon, "can't be set for #{Status.plural(status)} taxa"
      elsif Status.requires_current_taxon?(status) && !current_taxon
        errors.add :current_taxon, "must be set for #{Status.plural(status)}"
      end

      validate_current_taxon_rank
    end

    def validate_current_taxon_rank
      return unless current_taxon
      return if Rank.group_rank(type) == Rank.group_rank(current_taxon.type)

      errors.add :current_taxon, "must be of same rank as taxon"
    end

    def ensure_correct_name_type
      return if name&.taxon_type == type
      errors.add :base, "Rank (`#{self.class}`) and name type (`#{name.class}`) must match."
    end
end
