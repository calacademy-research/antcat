class Taxon < ApplicationRecord
  include Workflow
  include Workflow::ExternalTable

  include RevisionsCanBeCompared
  include Trackable

  TYPES = %w[Family Subfamily Tribe Subtribe Genus Subgenus Species Subspecies Infrasubspecies]
  TYPES_ABOVE_GENUS = %w[Family Subfamily Subtribe Tribe]
  TYPES_ABOVE_SPECIES = %w[Family Subfamily Tribe Subtribe Genus Subgenus]
  # TODO: Not validated since `taxa.type_taxon_id` will be moved to `protonyms` or a new table.
  CAN_HAVE_TYPE_TAXON_TYPES = TYPES_ABOVE_SPECIES
  # TODO: I don't think this is 100% true in the world of taxonomy, but it's close enough for our usage.
  CAN_BE_A_COMBINATION_TYPES = %w[Genus Subgenus Species Subspecies Infrasubspecies]

  TAXA_FIELDS_REFERENCING_TAXA = [:subfamily_id, :tribe_id, :genus_id, :subgenus_id,
    :species_id, :homonym_replaced_by_id, :current_valid_taxon_id, :type_taxon_id]
  INCERTAE_SEDIS_IN_RANKS = [
    INCERTAE_SEDIS_IN_FAMILY = 'family',
    INCERTAE_SEDIS_IN_SUBFAMILY = 'subfamily',
    'tribe',
    'genus'
  ]

  self.table_name = :taxa

  with_options class_name: 'Taxon' do
    belongs_to :type_taxon, foreign_key: :type_taxon_id
    belongs_to :genus
    belongs_to :homonym_replaced_by
    belongs_to :current_valid_taxon

    has_many :current_valid_taxon_of, foreign_key: :current_valid_taxon_id, dependent: :restrict_with_error
    has_many :junior_synonyms, -> { synonyms }, foreign_key: :current_valid_taxon_id
    has_many :obsolete_combinations, -> { obsolete_combinations }, foreign_key: :current_valid_taxon_id
  end

  belongs_to :name, dependent: :destroy
  belongs_to :protonym

  has_many :history_items, -> { order(:position) }, class_name: 'TaxonHistoryItem', dependent: :destroy
  has_many :reference_sections, -> { order(:position) }, dependent: :destroy
  has_one :taxon_state, dependent: false

  validates :name, :protonym, presence: true
  validates :status, inclusion: { in: Status::STATUSES }
  validates :incertae_sedis_in, inclusion: { in: INCERTAE_SEDIS_IN_RANKS, allow_nil: true }
  validates :homonym_replaced_by, absence: { message: "can't be set for non-homonyms" }, unless: -> { homonym? }
  validates :homonym_replaced_by, presence: { message: "must be set for homonyms" }, if: -> { homonym? }
  validates :unresolved_homonym, absence: { message: "can't be set for homonyms" }, if: -> { homonym? }
  validates :original_combination, absence: { message: "can not be set for taxa of this rank" }, unless: -> { type.in?(CAN_BE_A_COMBINATION_TYPES) }
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
  scope :pass_through_names, -> { where(status: Status::PASS_THROUGH_NAMES) }
  scope :excluding_pass_through_names, -> { where.not(status: Status::PASS_THROUGH_NAMES) }
  scope :order_by_epithet, -> { joins(:name).order('names.epithet') }
  scope :order_by_name, -> { order(:name_cache) }
  # TODO: Find a better name for these and figure out how to best use it.
  scope :with_common_includes, -> do
    includes(:name, protonym: [:name, { authorship: { reference: :author_names } }]).references(:reference_author_names)
  end
  scope :with_common_includes_and_current_valid_taxon_includes, -> do
    with_common_includes.
      includes(current_valid_taxon: [:name, protonym: [:name, { authorship: { reference: :author_names } }]])
  end

  # Example: `Species.self_join_on(:genus).where(fossil: false, taxa_self_join_alias: { fossil: true })`.
  scope :self_join_on, ->(model) {
    joins("LEFT OUTER JOIN `taxa` `taxa_self_join_alias` ON `taxa`.`#{model}_id` = `taxa_self_join_alias`.`id`")
  }

  accepts_nested_attributes_for :name, update_only: true
  accepts_nested_attributes_for :protonym

  has_paper_trail meta: { change_id: proc { UndoTracker.current_change_id } }
  strip_attributes only: [:incertae_sedis_in, :type_taxt, :headline_notes_taxt], replace_newlines: true
  trackable parameters: proc {
    if parent
      parent_params = { rank: parent.rank, name: parent.name_html_cache, id: parent.id }
    end
    { rank: rank, name: name_html_cache, parent: parent_params }
  }
  workflow do
    state TaxonState::OLD
    state TaxonState::WAITING do
      event :approve, transitions_to: TaxonState::APPROVED
    end
    state TaxonState::APPROVED
  end

  def self.name_clash? name_string
    where(name_cache: name_string).exists?
  end

  (Status::STATUSES - [Status::VALID]).each do |status|
    define_method "#{status.downcase.tr(' ', '_')}?" do
      self.status == status
    end
  end

  # Because `#valid?` clashes with ActiveModel.
  def valid_taxon?
    status == Status::VALID
  end

  def invalid?
    status != Status::VALID
  end

  # Overridden in `SpeciesGroupTaxon` (only species and subspecies can be recombinations)
  def recombination?
    false
  end

  def rank
    type.downcase
  end

  def name_class
    "#{type}Name".constantize
  end

  def epithet_with_fossil
    name.epithet_with_fossil_html fossil?
  end

  def name_with_fossil
    name.name_with_fossil_html fossil?
  end

  def expanded_status
    Taxa::ExpandedStatus[self]
  end

  def compact_status
    Taxa::CompactStatus[self]
  end

  def author_citation
    citation = authorship_reference.keey_without_letters_in_year

    if recombination?
      '('.html_safe + citation + ')'
    else
      citation
    end
  end

  def virtual_history_items
    @virtual_history_items ||= all_virtual_history_items.select(&:publicly_visible?)
  end

  # The reason we have `#virtual_history_items` and `#all_virtual_history_items` is because for as long as
  # data is being migrated to "virtual history items", we want to be able to "preview" items before we actually make
  # them publicly visible in the catalog.
  def all_virtual_history_items
    @all_virtual_history_items ||= VirtualHistoryItemsForTaxon[self]
  end

  def policy
    @policy ||= TaxonPolicy.new(self)
  end

  def link_to_taxon
    %(<a href="/catalog/#{id}">#{name_with_fossil}</a>).html_safe
  end

  def authorship_reference
    protonym.authorship.reference
  end

  def last_change
    Change.joins(:versions).where("versions.item_id = ? AND versions.item_type = 'Taxon'", id).last
  end

  def soft_validations
    @soft_validations ||= SoftValidations.new(self, SoftValidations::TAXA_DATABASE_SCRIPTS_TO_CHECK)
  end

  def what_links_here
    @what_links_here ||= Taxa::WhatLinksHere.new(self)
  end

  # TODO: Experimental.
  def now
    return self unless current_valid_taxon
    current_valid_taxon.now
  end

  # TODO: Remove ASAP. Also `#synonyms_history_items_containing_taxons_protonyms_taxa`.
  def obsolete_combination_that_is_probably_a_synonym?
    DatabaseScripts::ObsoleteCombinationsWithProtonymsNotMatchingItsCurrentValidTaxonsProtonym.record_in_results?(self) ||
      DatabaseScripts::ObsoleteCombinationsWithVeryDifferentEpithets.record_in_results?(self)
  end

  # TODO: Remove ASAP. Also `#obsolete_combination_that_is_probably_a_synonym`.
  def synonyms_history_items_containing_taxons_protonyms_taxa taxon
    taxon.protonym.taxa.each do |protonym_taxon|
      item = history_items.find_by("taxt LIKE ?", "Senior synonym of%#{protonym_taxon.id}%")
      return item if item
    end
    nil
  end

  # TODO: Remove once subspecies lists have been cleaned up.
  # See https://github.com/calacademy-research/antcat/issues/780
  def subspecies_list_in_history_items
    history_items.where('taxt LIKE ?', "%Current subspecies%")
  end

  # TODO: Experimental.
  def collected_references
    @collected_references ||= Taxa::CollectReferences[self]
  end

  private

    def set_name_caches
      self.name_cache = name.name
      self.name_html_cache = name.name_html
    end

    def cleanup_taxts
      self.headline_notes_taxt = Taxt::Cleanup[headline_notes_taxt]
      self.type_taxt = Taxt::Cleanup[type_taxt]
    end

    def current_valid_taxon_validation
      if cannot_have_current_valid_taxon? && current_valid_taxon
        errors.add :current_valid_name, "can't be set for #{Status.plural(status)} taxa"
      elsif requires_current_valid_taxon? && !current_valid_taxon
        errors.add :current_valid_name, "must be set for #{Status.plural(status)}"
      end
    end

    def cannot_have_current_valid_taxon?
      status.in? Status::CURRENT_VALID_TAXON_VALIDATION[:absence]
    end

    def requires_current_valid_taxon?
      status.in? Status::CURRENT_VALID_TAXON_VALIDATION[:presence]
    end

    def ensure_correct_name_type
      return if name.is_a? name_class
      return if name.class.name.in? Name::BROKEN_ISH_NAME_TYPES # Make sure taxa already in this state can be saved.
      error_message = "Rank (`#{self.class}`) and name type (`#{name.class}`) must match."
      errors.add :base, error_message unless errors.added? :base, error_message
    end
end
