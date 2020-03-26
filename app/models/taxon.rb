# frozen_string_literal: true

class Taxon < ApplicationRecord
  include Trackable

  self.table_name = :taxa

  delegate(*CleanupTaxon::DELEGATED_IN_TAXON, to: :cleanup_taxon)

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

  validates :name, :protonym, presence: true
  validates :status, inclusion: { in: Status::STATUSES }
  validates :incertae_sedis_in, inclusion: { in: Rank::INCERTAE_SEDIS_IN_RANKS, allow_nil: true }
  validates :homonym_replaced_by, absence: { message: "can't be set for non-homonyms" }, unless: -> { homonym? }
  validates :homonym_replaced_by, presence: { message: "must be set for homonyms" }, if: -> { homonym? }
  validates :unresolved_homonym, absence: { message: "can't be set for homonyms" }, if: -> { homonym? }
  validates :original_combination, absence: { message: "can not be set for taxa of this rank" },
    unless: -> { type.in?(Rank::CAN_BE_A_COMBINATION_TYPES) }
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
  # TODO: Find a better name and place for these and figure out how to best use them.
  scope :with_common_includes, -> do
    includes(:name, protonym: [:name, { authorship: { reference: :author_names } }]).references(:reference_author_names)
  end
  scope :with_common_includes_and_current_valid_taxon_includes, -> do
    with_common_includes.
      includes(current_valid_taxon: [:name, protonym: [:name, { authorship: { reference: :author_names } }]])
  end

  accepts_nested_attributes_for :name, update_only: true
  accepts_nested_attributes_for :protonym
  has_paper_trail
  strip_attributes only: [:incertae_sedis_in, :origin, :type_taxt, :headline_notes_taxt], replace_newlines: true
  trackable parameters: proc {
    parent_params = { rank: parent.rank, name: parent.name_html_cache, id: parent.id } if parent
    { rank: rank, name: name_html_cache, parent: parent_params }
  }

  def self.name_clash? name_string
    where(name_cache: name_string).exists?
  end

  [Status::SYNONYM, Status::HOMONYM, Status::UNIDENTIFIABLE, Status::UNAVAILABLE].each do |status|
    define_method "#{status.downcase.tr(' ', '_')}?" do
      self.status == status
    end
  end

  # Because `#valid?` clashes with ActiveModel.
  def valid_taxon?
    status == Status::VALID
  end

  def invalid?
    !valid_taxon?
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

  def expanded_status
    Taxa::ExpandedStatus[self]
  end

  def compact_status
    Taxa::CompactStatus[self]
  end

  def author_citation
    citation = authorship_reference.keey_without_letters_in_year
    return citation unless is_a?(SpeciesGroupTaxon) && recombination?
    '('.html_safe + citation + ')'
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

  # TODO: This does not belong in the model. It was moved here to make it easier to refactor `Name`,
  # and for performance reasons in the taxon browser since decorating a lot of taxa took its toll.
  # Move somewhere once we have improved `Name` and the taxon browser.
  def link_to_taxon
    %(<a href="/catalog/#{id}">#{name_with_fossil}</a>).html_safe
  end

  def authorship_reference
    protonym.authorship.reference
  end

  def soft_validations
    @soft_validations ||= SoftValidations.new(self, SoftValidations::TAXA_DATABASE_SCRIPTS_TO_CHECK)
  end

  def what_links_here
    @what_links_here ||= Taxa::WhatLinksHere.new(self)
  end

  def cleanup_taxon
    @cleanup_taxon ||= CleanupTaxon.new(self)
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
      error_message = "Rank (`#{self.class}`) and name type (`#{name.class}`) must match."
      errors.add :base, error_message unless errors.added? :base, error_message
    end
end
