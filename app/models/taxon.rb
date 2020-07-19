# frozen_string_literal: true

class Taxon < ApplicationRecord
  include Trackable

  self.table_name = :taxa

  delegate :policy, :soft_validations, :what_links_here, :virtual_history_items, :all_virtual_history_items,
    to: :taxon_collaborators

  with_options class_name: 'Taxon' do
    # TODO: `belongs_to :genus` should not be here, but at least used to be required for the advanced search.
    # Now it's also used in the editors's sidebar (Ctrl+F "belongs_to :genus").
    belongs_to :genus, optional: true
    belongs_to :homonym_replaced_by, optional: true
    belongs_to :current_taxon, optional: true

    has_many :current_taxon_of, foreign_key: :current_taxon_id, dependent: :restrict_with_error
    has_many :junior_synonyms, -> { synonyms }, foreign_key: :current_taxon_id
    has_many :obsolete_combinations, -> { obsolete_combinations }, foreign_key: :current_taxon_id
  end

  belongs_to :name, dependent: :destroy
  belongs_to :protonym

  with_options inverse_of: :taxon, dependent: :destroy do
    has_many :history_items, -> { order(:position) }, class_name: 'TaxonHistoryItem'
    has_many :reference_sections, -> { order(:position) }
  end

  has_one :authorship, through: :protonym
  has_one :authorship_reference, through: :authorship, source: :reference
  has_many :type_names, dependent: :restrict_with_error

  validates :status, inclusion: { in: Status::STATUSES }
  validates :incertae_sedis_in, inclusion: { in: Rank::INCERTAE_SEDIS_IN_TYPES, allow_nil: true }
  validates :homonym_replaced_by, absence: { message: "can't be set for non-homonyms" }, unless: -> { homonym? }
  validates :homonym_replaced_by, presence: { message: "must be set for homonyms" }, if: -> { homonym? }
  validates :unresolved_homonym, absence: { message: "can't be set for homonyms" }, if: -> { homonym? }
  validates :nomen_nudum, absence: { message: "can only be set for unavailable taxa" }, unless: -> { unavailable? }
  validates :ichnotaxon, absence: { message: "can only be set for fossil taxa" }, unless: -> { fossil? }
  validates :collective_group_name, absence: { message: "can only be set for fossil taxa" }, unless: -> { fossil? }
  validate :current_taxon_validation, :ensure_correct_name_type

  before_save :set_name_caches

  scope :valid, -> { where(status: Status::VALID) }
  scope :invalid, -> { where.not(status: Status::VALID) }
  scope :extant, -> { where(fossil: false) }
  scope :fossil, -> { where(fossil: true) }
  scope :obsolete_combinations, -> { where(status: Status::OBSOLETE_COMBINATION) }
  scope :synonyms, -> { where(status: Status::SYNONYM) }
  scope :order_by_name, -> { order(:name_cache) }

  accepts_nested_attributes_for :name, update_only: true
  has_paper_trail
  strip_attributes only: [:incertae_sedis_in], replace_newlines: true
  trackable parameters: proc {
    parent_params = { rank: parent.rank, name: parent.name_html_cache, id: parent.id } if parent
    { rank: rank, name: name_html_cache, parent: parent_params }
  }

  [Status::SYNONYM, Status::HOMONYM, Status::UNIDENTIFIABLE, Status::UNAVAILABLE, Status::EXCLUDED_FROM_FORMICIDAE].each do |status|
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
    name.name_with_fossil_html fossil?
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

  def taxon_collaborators
    @_taxon_collaborators ||= Taxa::TaxonCollaborators.new(self)
  end

  private

    def set_name_caches
      self.name_cache = name.name
      self.name_html_cache = name.name_html
    end

    def current_taxon_validation
      if Status.cannot_have_current_taxon?(status) && current_taxon
        errors.add :current_taxon, "can't be set for #{Status.plural(status)} taxa"
      elsif Status.requires_current_taxon?(status) && !current_taxon
        errors.add :current_taxon, "must be set for #{Status.plural(status)}"
      end
    end

    def ensure_correct_name_type
      return if name&.taxon_type == type
      errors.add :base, "Rank (`#{self.class}`) and name type (`#{name.class}`) must match."
    end
end
