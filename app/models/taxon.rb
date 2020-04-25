# frozen_string_literal: true

class Taxon < ApplicationRecord
  include Trackable

  self.table_name = :taxa

  delegate :now, :most_recent_before_now, to: :cleanup_taxon
  delegate :policy, :soft_validations, :what_links_here, :virtual_history_items, :all_virtual_history_items,
    to: :taxon_collaborators

  with_options class_name: 'Taxon' do
    belongs_to :type_taxon, foreign_key: :type_taxon_id, optional: true
    # TODO: `belongs_to :genus` should not be here, but at least used to be required for the advanced search.
    # Now it's also used in the editors's sidebar (Ctrl+F "belongs_to :genus").
    belongs_to :genus, optional: true
    belongs_to :homonym_replaced_by, optional: true
    belongs_to :current_valid_taxon, optional: true

    has_many :current_valid_taxon_of, foreign_key: :current_valid_taxon_id, dependent: :restrict_with_error
    has_many :junior_synonyms, -> { synonyms }, foreign_key: :current_valid_taxon_id
    has_many :obsolete_combinations, -> { obsolete_combinations }, foreign_key: :current_valid_taxon_id
  end

  belongs_to :name, dependent: :destroy
  belongs_to :protonym

  with_options inverse_of: :taxon, dependent: :destroy do
    has_many :history_items, -> { order(:position) }, class_name: 'TaxonHistoryItem'
    has_many :reference_sections, -> { order(:position) }
  end

  has_one :authorship, through: :protonym
  has_one :authorship_reference, through: :authorship, source: :reference

  validates :status, inclusion: { in: Status::STATUSES }
  validates :incertae_sedis_in, inclusion: { in: Rank::INCERTAE_SEDIS_IN_RANKS, allow_nil: true }
  validates :homonym_replaced_by, absence: { message: "can't be set for non-homonyms" }, unless: -> { homonym? }
  validates :homonym_replaced_by, presence: { message: "must be set for homonyms" }, if: -> { homonym? }
  validates :unresolved_homonym, absence: { message: "can't be set for homonyms" }, if: -> { homonym? }
  validates :nomen_nudum, absence: { message: "can only be set for unavailable taxa" }, unless: -> { unavailable? }
  validates :ichnotaxon, absence: { message: "can only be set for fossil taxa" }, unless: -> { fossil? }
  validates :collective_group_name, absence: { message: "can only be set for fossil taxa" }, unless: -> { fossil? }
  validates :type_taxt, absence: { message: "(type notes) can't be set unless taxon has a type name" }, unless: -> { type_taxon }
  validate :current_valid_taxon_validation, :ensure_correct_name_type

  before_validation :cleanup_taxts
  before_save :set_name_caches

  scope :valid, -> { where(status: Status::VALID) }
  scope :invalid, -> { where.not(status: Status::VALID) }
  scope :extant, -> { where(fossil: false) }
  scope :fossil, -> { where(fossil: true) }
  scope :obsolete_combinations, -> { where(status: Status::OBSOLETE_COMBINATION) }
  scope :synonyms, -> { where(status: Status::SYNONYM) }
  scope :order_by_name, -> { order(:name_cache) }

  accepts_nested_attributes_for :name, update_only: true
  accepts_nested_attributes_for :protonym
  has_paper_trail
  strip_attributes only: [:incertae_sedis_in, :origin, :type_taxt, :headline_notes_taxt], replace_newlines: true
  trackable parameters: proc {
    parent_params = { rank: parent.rank, name: parent.name_html_cache, id: parent.id } if parent
    { rank: rank, name: name_html_cache, parent: parent_params }
  }

  [Status::SYNONYM, Status::HOMONYM, Status::UNIDENTIFIABLE, Status::UNAVAILABLE].each do |status|
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
    citation = authorship_reference.keey_without_letters_in_year
    return citation unless is_a?(SpeciesGroupTaxon) && recombination?
    '('.html_safe + citation + ')'
  end

  # TODO: This does not belong in the model. It was moved here to make it easier to refactor `Name`.
  def link_to_taxon
    css_classes = CatalogFormatter.disco_mode_css(self)
    %(<a class="#{css_classes}" href="/catalog/#{id}">#{name_with_fossil}</a>).html_safe
  end

  def taxon_collaborators
    @_taxon_collaborators ||= Taxa::TaxonCollaborators.new(self)
  end

  def cleanup_taxon
    @_cleanup_taxon ||= Taxa::CleanupTaxon.new(self)
  end

  private

    def set_name_caches
      self.name_cache = name.name
      self.name_html_cache = name.name_html
    end

    # TODO: Remove. `taxa.type_taxt` should be moved and normalized; `taxa.headline_notes_taxt` can
    # be distributed into other taxts.
    def cleanup_taxts
      self.headline_notes_taxt = Taxt::Cleanup[headline_notes_taxt]
      self.type_taxt = Taxt::Cleanup[type_taxt]
    end

    def current_valid_taxon_validation
      if Status.cannot_have_current_valid_taxon?(status) && current_valid_taxon
        errors.add :current_valid_name, "can't be set for #{Status.plural(status)} taxa"
      elsif Status.requires_current_valid_taxon?(status) && !current_valid_taxon
        errors.add :current_valid_name, "must be set for #{Status.plural(status)}"
      end
    end

    def ensure_correct_name_type
      return if name&.rank == rank
      errors.add :base, "Rank (`#{self.class}`) and name type (`#{name.class}`) must match."
    end
end
