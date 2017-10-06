# TODO avoid `require`.

require_dependency 'taxon_workflow'

class Taxon < ApplicationRecord
  include Taxa::CallbacksAndValidations
  include Taxa::Delete
  include Taxa::PredicateMethods
  include Taxa::ReorderHistoryItems
  include Taxa::Statistics
  include Taxa::Synonyms
  include RevisionsCanBeCompared
  include Trackable

  TAXA_FIELDS_REFERENCING_TAXA = [:subfamily_id, :tribe_id, :genus_id, :subgenus_id,
    :species_id, :homonym_replaced_by_id, :current_valid_taxon_id]

  class TaxonExists < StandardError; end

  self.table_name = :taxa

  # `attr_accessor` (Ruby built-in): convenient when we want to store temporary values.
  # These are used in the edit taxa form / `TaxaController`
  attr_accessor :parent_name, :current_valid_taxon_name, :homonym_replaced_by_name,
    :duplicate_type

  # Set to true enable additional callbacks for this taxon only. Used in relation
  # to `TaxaController`, but can be used in the console/anywhere as well.
  attr_accessor :save_initiator

  # `attr_accessible` (Rails method): to protect from mass-assignment. You can ignore these.
  attr_accessible :auto_generated, :biogeographic_region, :collision_merge_id,
    :display, :fossil, :headline_notes_taxt, :hong, :ichnotaxon, :id, :incertae_sedis_in,
    :name, :name_id, :nomen_nudum, :origin, :protonym, :status, :type_fossil, :type_name,
    :type_name_id, :type_specimen_code, :type_specimen_repository, :type_specimen_url,
    :type_taxt, :unresolved_homonym, :verbatim_type_locality

  # TODO remove column `:collision_merge_id` (not used, all nil).
  # TODO maybe explain more of these. Here or elsewhere.
  # `origin`: if it's generated, where did it come from? string (e.g.: 'hol')
  # `display`: if false, won't show in the taxon browser. Used for misspellings and such.

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

  scope :displayable, -> { where(display: true) }
  scope :valid, -> { where(status: 'valid') }
  scope :extant, -> { where(fossil: false) }
  scope :order_by_joined_epithet, -> { joins(:name).order('names.epithet') }
  scope :order_by_name_cache, -> { order(:name_cache) }
  # For making conditional queries on self-referential `Taxon` associations.
  #
  # `#includes` and `#joins` are really hard to use because `Taxon` is a STI
  # model with self-referential associations; it's name is irregular in plural,
  # and some of its associations have irregular plurals or singulars.
  #
  # Example usage:
  # Say we want something like this (which doesn't work):
  #   `Species.joins(:genera).where(fossil: false, genus: { fossil: true })`
  #
  # Then use this:
  #   `Species.self_join_on(:genus)
  #      .where(fossil: false, taxa_self_join_alias: { fossil: true })`
  scope :self_join_on, -> (model) {
    joins(<<-SQL.squish)
      LEFT OUTER JOIN `taxa` `taxa_self_join_alias`
        ON `taxa`.`#{model}_id` = `taxa_self_join_alias`.`id`
      SQL
  }
  scope :ranks, -> (*ranks) { where(type: ranks) }
  scope :exclude_ranks, -> (*ranks) { where.not(type: ranks) }

  accepts_nested_attributes_for :name, :protonym, :type_name
  has_paper_trail meta: { change_id: proc { UndoTracker.get_current_change_id } }
  tracked on: :mixin_create_activity_only, parameters: proc {
    parent_params = { rank: parent.rank,
                      name: parent.name_html_cache,
                      id:   parent.id } if parent
    { rank: rank, name: name_html_cache, parent: parent_params }
  }

  # Avoid this method. Issues:
  # It conflicts with dynamic finder methods with the same names (they should be avoided too).
  # It searches in `taxa.name_cache`, not `names.name`.
  # It silently returns the first match if there's more than 1.
  #
  # More stuff:
  # `Taxon.where(name_cache: "Acamathus").count` returns two matches
  # `Taxon.find_by_name("Acamathus")` returns a single item
  # `Taxon.find_by_sql("SELECT * FROM taxa GROUP BY name_cache HAVING COUNT(*) > 1").count` = 857
  # Other methods clashing with dynamic finders: `Author.find_by_names`, `Name.find_by_name`.
  def self.find_by_name name
    find_by(name_cache: name)
  end

  def save_from_form params, previous_combination = nil
    Taxa::SaveFromForm[self, params, previous_combination]
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
end
