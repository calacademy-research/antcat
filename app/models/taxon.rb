class Taxon < ApplicationRecord
  include Workflow
  include Workflow::ExternalTable

  include Taxa::CallbacksAndValidations
  include RevisionsCanBeCompared
  include Trackable

  ALLOW_CREATE_COMBINATION_RANKS = %w[species subspecies]
  ALLOW_FORCE_CHANGE_PARENT_RANKS = %w[tribe genus subgenus species subspecies]
  TAXA_FIELDS_REFERENCING_TAXA = [:subfamily_id, :tribe_id, :genus_id, :subgenus_id,
    :species_id, :homonym_replaced_by_id, :current_valid_taxon_id, :type_taxon_id]

  class TaxonExists < StandardError; end

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

    has_one :homonym_replaced, foreign_key: :homonym_replaced_by_id, dependent: :restrict_with_error
    has_many :junior_synonyms, -> { where(status: Status::SYNONYM) }, foreign_key: :current_valid_taxon_id
  end

  belongs_to :name, dependent: :destroy
  belongs_to :protonym, -> { includes :authorship }

  has_many :history_items, -> { order(:position) }, class_name: 'TaxonHistoryItem', dependent: :destroy
  has_many :reference_sections, -> { order(:position) }, dependent: :destroy
  has_one :taxon_state

  scope :valid, -> { where(status: Status::VALID) }
  scope :extant, -> { where(fossil: false) }
  scope :fossil, -> { where(fossil: true) }
  scope :pass_through_names, -> { where(status: Status::PASS_THROUGH_NAMES) }
  scope :order_by_epithet, -> { joins(:name).order('names.epithet') }
  scope :order_by_name, -> { order(:name_cache) }

  # Example: `Species.self_join_on(:genus).where(fossil: false, taxa_self_join_alias: { fossil: true })`.
  scope :self_join_on, ->(model) {
    joins("LEFT OUTER JOIN `taxa` `taxa_self_join_alias` ON `taxa`.`#{model}_id` = `taxa_self_join_alias`.`id`")
  }

  accepts_nested_attributes_for :name, update_only: true
  accepts_nested_attributes_for :protonym

  has_paper_trail meta: { change_id: proc { UndoTracker.get_current_change_id } }
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

  def link_to_taxon
    %(<a href="/catalog/#{id}">#{name_with_fossil}</a>).html_safe
  end

  def authorship_reference
    protonym.authorship.reference
  end

  def last_change
    Change.joins(:versions).where("versions.item_id = ? AND versions.item_type = 'Taxon'", id).last
  end

  def what_links_here predicate: false
    Taxa::WhatLinksHere[self, predicate: predicate]
  end
end
