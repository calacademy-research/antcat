require_dependency 'taxon_workflow'

class Taxon < ActiveRecord::Base
  include UndoTracker
  include Taxa::CallbacksAndValidators
  include Taxa::Delete
  include Taxa::PredicateMethods
  include Taxa::References
  include Taxa::Statistics
  include Taxa::Synonyms

  include Feed::Trackable
  tracked on: :create, parameters: activity_parameters

  class TaxonExists < StandardError; end

  self.table_name = :taxa
  has_paper_trail meta: { change_id: :get_current_change_id }

  attr_accessible :name_id,
                  :status,
                  :incertae_sedis_in,
                  :fossil,
                  :nomen_nudum,
                  :unresolved_homonym,
                  :ichnotaxon,
                  :hong,
                  :headline_notes_taxt,
                  :biogeographic_region,
                  :verbatim_type_locality,
                  :type_specimen_repository,
                  :type_specimen_code,
                  :type_specimen_url,
                  :type_fossil,
                  :type_taxt,
                  :type_name_id,
                  :collision_merge_id,
                  :name,
                  :protonym,
                  :type_name,
                  :id,
                  :auto_generated,
                  :origin, #if it's generated, where did it come from? string (e.g.: 'hol')
                  :display # if false, won't show in the taxon browser. Used for misspellings and such.

  attr_accessor :authorship_string, :duplicate_type, :parent_name,
    :current_valid_taxon_name, :homonym_replaced_by_name

  delegate :authorship_html_string, :author_last_names_string, :year, to: :protonym

  belongs_to :name
  belongs_to :protonym, -> { includes :authorship }
  belongs_to :type_name, class_name: 'Name', foreign_key: :type_name_id
  belongs_to :genus, class_name: 'Taxon'
  belongs_to :homonym_replaced_by, class_name: 'Taxon'
  belongs_to :current_valid_taxon, class_name: 'Taxon'

  has_one :homonym_replaced, class_name: 'Taxon', foreign_key: :homonym_replaced_by_id
  has_many :taxa, class_name: "Taxon", foreign_key: :genus_id
  has_many :synonyms_as_junior, foreign_key: :junior_synonym_id, class_name: 'Synonym'
  has_many :synonyms_as_senior, foreign_key: :senior_synonym_id, class_name: 'Synonym'
  has_many :junior_synonyms, through: :synonyms_as_senior
  has_many :senior_synonyms, through: :synonyms_as_junior
  has_many :history_items, -> { order(:position) }, class_name: 'TaxonHistoryItem', dependent: :destroy
  has_many :reference_sections, -> { order(:position) }, dependent: :destroy

  scope :displayable, -> { where(display: true) }
  scope :valid, -> { where(status: 'valid') }
  scope :extant, -> { where(fossil: false) }
  scope :order_by_joined_epithet, -> { joins(:name).order('names.epithet') }
  scope :order_by_name_cache, -> { order(:name_cache) }

  accepts_nested_attributes_for :name, :protonym, :type_name

  def save_taxon params, previous_combination = nil
    Taxa::SaveTaxon.new(self).save_taxon(params, previous_combination)
  end

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

  def update_parent new_parent
    return if self.parent == new_parent
    self.name.change_parent new_parent.name
    set_name_caches
    self.parent = new_parent
    self.subfamily = new_parent.subfamily
  end

  def rank
    self.type.downcase
  end

  # TODO only used in `Exporters::Antweb::Exporter`? move maybe
  # The original_combination accessor returns the taxon with 'original combination'
  # status whose 'current valid taxon' points to us.
  def original_combination
    self.class.where(status: 'original combination', current_valid_taxon_id: id).first
  end

  # TODO: this triggers a save in the Name model for some reason.
  def authorship_string
    string = protonym.authorship_string
    if string && recombination?
      string = '(' + string + ')'
    end
    string
  end

  def self_and_parents
    parents = []
    current_taxon = self

    while current_taxon
      parents << current_taxon
      current_taxon = current_taxon.parent
    end
    parents.reverse
  end

  private
    def activity_parameters
      ->(taxon) do
        hash = { rank: taxon.rank,
                 name: taxon.name_html_cache }

        parent = taxon.parent
        hash[:parent] = { rank: parent.rank,
                          name: parent.name_html_cache,
                          id: parent.id } if parent
        hash
      end
    end
end
