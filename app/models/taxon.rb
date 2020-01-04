class Taxon < ApplicationRecord
  include Workflow
  include Workflow::ExternalTable

  include RevisionsCanBeCompared
  include Trackable

  TYPES = %w[Family Subfamily Tribe Subtribe Genus Subgenus Species Subspecies Infrasubspecies]
  TAXA_FIELDS_REFERENCING_TAXA = [:subfamily_id, :tribe_id, :genus_id, :subgenus_id,
    :species_id, :homonym_replaced_by_id, :current_valid_taxon_id, :type_taxon_id]
  INCERTAE_SEDIS_IN_RANKS = [
    INCERTAE_SEDIS_IN_FAMILY = 'family',
    INCERTAE_SEDIS_IN_SUBFAMILY = 'subfamily',
    'tribe',
    'genus'
  ]

  class TaxonExists < StandardError
    attr_reader :names

    def initialize names
      @names = names
    end
  end

  # TODO: Decide what do do with these.
  class TaxonHasSubspecies < StandardError; end
  class TaxonHasInfrasubspecies < StandardError; end

  # TODO: Extract this and all `#update_parent`s into `ForceParentChange`.
  class InvalidParent < StandardError
    attr_reader :taxon, :new_parent

    def initialize taxon, new_parent = nil
      @taxon = taxon
      @new_parent = new_parent
    end

    def message
      "Invalid parent: ##{new_parent&.id} (#{new_parent&.rank}) for ##{taxon.id} (#{taxon.rank})"
    end
  end

  self.table_name = :taxa

  # Set to true enable additional callbacks for this taxon only (set taxon state, etc).
  attr_accessor :save_initiator

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
  # TODO: Do not include authorship.
  belongs_to :protonym, -> { includes :authorship }

  has_many :history_items, -> { order(:position) }, class_name: 'TaxonHistoryItem', dependent: :destroy
  has_many :reference_sections, -> { order(:position) }, dependent: :destroy
  has_one :taxon_state, dependent: false

  validates :name, :protonym, presence: true
  validates :status, inclusion: { in: Status::STATUSES }
  validates :incertae_sedis_in, inclusion: { in: INCERTAE_SEDIS_IN_RANKS, allow_nil: true }
  validates :homonym_replaced_by, absence: { message: "can't be set for non-homonyms" }, unless: -> { homonym? }
  validates :homonym_replaced_by, presence: { message: "must be set for homonyms" }, if: -> { homonym? }
  validates :unresolved_homonym, absence: { message: "can't be set for homonyms" }, if: -> { homonym? }
  validates :nomen_nudum, absence: { message: "can only be set for unavailable taxa" }, unless: -> { unavailable? }
  validates :type_taxt, absence: { message: "(type notes) can't be set unless taxon has a type name" }, unless: -> { type_taxon }

  validate :current_valid_taxon_validation, :ensure_correct_name_type

  before_validation :cleanup_taxts
  before_save :set_name_caches
  before_save { remove_auto_generated if save_initiator } # TODO: Move or remove.
  before_save { set_taxon_state_to_waiting if save_initiator } # TODO: Move or remove.

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

  def self.name_clash? name
    where(name_cache: name).exists?
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

  def what_links_here predicate: false
    Taxa::WhatLinksHere[self, predicate: predicate]
  end

  # TODO: Experimental.
  def now
    return self unless current_valid_taxon
    current_valid_taxon.now
  end

  # TODO: Remove once subspecies lists have been cleaned up.
  # See https://github.com/calacademy-research/antcat/issues/780
  def subspecies_list_in_history_items
    history_items.where('taxt LIKE ?', "%Current subspecies%")
  end

  private

    def set_name_caches
      self.name_cache = name.name
      self.name_html_cache = name.name_html
    end

    def remove_auto_generated
      self.auto_generated = false
    end

    def set_taxon_state_to_waiting
      taxon_state.review_state = TaxonState::WAITING
      taxon_state.save
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
