# TODO avoid `require`.

require_dependency 'taxon_workflow'

class Taxon < ApplicationRecord
  include Taxa::CallbacksAndValidations
  include Taxa::PredicateMethods
  include Taxa::Synonyms
  include RevisionsCanBeCompared
  include Trackable

  TAXA_FIELDS_REFERENCING_TAXA = [:subfamily_id, :tribe_id, :genus_id, :subgenus_id,
    :species_id, :homonym_replaced_by_id, :current_valid_taxon_id]

  class TaxonExists < StandardError; end

  self.table_name = :taxa

  attr_accessor :parent_name, :duplicate_type

  # Set to true enable additional callbacks for this taxon only (set taxon state, etc).
  attr_accessor :save_initiator

  # TODO remove column `:collision_merge_id` (not used, all nil).

  belongs_to :name
  belongs_to :protonym, -> { includes :authorship }
  belongs_to :type_name, class_name: 'Name', foreign_key: :type_name_id
  belongs_to :genus, class_name: 'Taxon'
  belongs_to :homonym_replaced_by, class_name: 'Taxon'
  belongs_to :current_valid_taxon, class_name: 'Taxon'

  has_one :homonym_replaced, class_name: 'Taxon', foreign_key: :homonym_replaced_by_id
  has_many :taxa, class_name: "Taxon", foreign_key: :genus_id # Only `genus_id`?
  has_many :history_items, -> { order(:position) }, class_name: 'TaxonHistoryItem', dependent: :destroy
  has_many :reference_sections, -> { order(:position) }, dependent: :destroy
  # Synonyms.
  has_many :synonyms_as_junior, foreign_key: :junior_synonym_id, class_name: 'Synonym'
  has_many :synonyms_as_senior, foreign_key: :senior_synonym_id, class_name: 'Synonym'
  has_many :junior_synonyms, through: :synonyms_as_senior
  has_many :senior_synonyms, through: :synonyms_as_junior
  # Note the reversed foreign key.
  has_many :junior_synonyms_objects, foreign_key: :senior_synonym_id, class_name: 'Synonym'
  has_many :senior_synonyms_objects, foreign_key: :junior_synonym_id, class_name: 'Synonym'
  # Confused? See this:
  # `dolichoderus = Taxon.find(429079)`    = valid taxon, not a synonym
  # `dolichoderus.junior_synonyms`         = 7 taxon objects
  # `dolichoderus.synonyms_as_junior`      = 0 synonym objects
  # `dolichoderus.junior_synonyms_objects` = 7 synonym objects

  scope :displayable, -> do
    where.not(status: [Status::UNAVAILABLE_MISSPELLING, Status::UNAVAILABLE_UNCATEGORIZED])
  end
  scope :valid, -> { where(status: Status::VALID) }
  scope :extant, -> { where(fossil: false) }
  scope :fossil, -> { where(fossil: true) }
  scope :pass_through_names, -> do
    where(
      status: [
        Status::OBSOLETE_COMBINATION, Status::ORIGINAL_COMBINATION, Status::UNAVAILABLE_MISSPELLING
      ]
    )
  end
  scope :order_by_joined_epithet, -> { joins(:name).order('names.epithet') }
  scope :order_by_name_cache, -> { order(:name_cache) }
  # For making conditional queries on self-referential `Taxon` associations.
  #
  # Example usage:
  # Say we want something like this (which doesn't work):
  #   `Species.joins(:genera).where(fossil: false, genus: { fossil: true })`
  #
  # Then use this:
  #   `Species.self_join_on(:genus)
  #      .where(fossil: false, taxa_self_join_alias: { fossil: true })`
  scope :self_join_on, ->(model) {
    joins(<<-SQL.squish)
      LEFT OUTER JOIN `taxa` `taxa_self_join_alias`
        ON `taxa`.`#{model}_id` = `taxa_self_join_alias`.`id`
    SQL
  }
  scope :ranks, ->(*ranks) { where(type: ranks) }
  scope :exclude_ranks, ->(*ranks) { where.not(type: ranks) }

  accepts_nested_attributes_for :name, :protonym, :type_name
  has_paper_trail meta: { change_id: proc { UndoTracker.get_current_change_id } }
  tracked on: :mixin_create_activity_only, parameters: proc {
    if parent
      parent_params = { rank: parent.rank,
                        name: parent.name_html_cache,
                        id:   parent.id }
    end
    { rank: rank, name: name_html_cache, parent: parent_params }
  }

  # TODO remove since `#name_cache` is not unique.
  def self.find_by_name name
    find_by(name_cache: name)
  end

  # TODO see if we can push this down to the subclasses.
  def update_parent new_parent
    return if parent == new_parent

    name.change_parent new_parent.name
    set_name_caches
    self.parent = new_parent
    self.subfamily = new_parent.subfamily
  end

  def rank
    type.downcase
  end

  def name_class
    "#{type}Name".constantize
  end

  def taxon_and_ancestors
    taxon_and_ancestors = []
    current_taxon = self

    while current_taxon
      taxon_and_ancestors << current_taxon
      current_taxon = current_taxon.parent
    end

    # Reversed to put Formicidae in the first tab and itself in last.
    taxon_and_ancestors.reverse
  end

  def taxon_label
    name.epithet_with_fossil_html fossil?
  end

  def name_with_fossil
    name.to_html_with_fossil fossil?
  end

  def author_citation
    return unless authorship_reference

    string = authorship_reference.keey_without_letters_in_year
    if string && recombination?
      string = '(' + string + ')'
    end
    string
  end

  def authorship_reference
    protonym.try(:authorship).try(:reference)
  end

  def what_links_here
    Taxa::WhatLinksHere[self]
  end

  def any_nontaxt_references?
    Taxa::AnyNonTaxtReferences[self]
  end

  def get_statistics ranks, valid_only: false
    Taxa::Statistics[self, ranks, valid_only: valid_only]
  end
end
