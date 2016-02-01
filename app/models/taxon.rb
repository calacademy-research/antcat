require_dependency 'taxon_workflow'

class Taxon < ActiveRecord::Base
  include UndoTracker
  include Taxa::CallbacksAndValidators
  include Taxa::Delete
  include Taxa::PredicateMethods
  include Taxa::References
  include Taxa::Statistics
  include Taxa::Synonyms

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

  delegate :authorship_html_string, :author_last_names_string, :year,
    to: :protonym

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
  has_many :history_items, -> { order 'position' }, class_name: 'TaxonHistoryItem', dependent: :destroy
  has_many :reference_sections, -> { order 'position' }, dependent: :destroy

  scope :displayable, -> { where(display: true) }
  scope :valid, -> { where(status: 'valid') }
  scope :extant, -> { where(fossil: false) }
  scope :with_names, -> { joins(:name).readonly(false) }
  scope :ordered_by_name, lambda { with_names.order('names.name').includes(:name) }

  accepts_nested_attributes_for :name, :protonym, :type_name

  def save_taxon params, previous_combination = nil
    Taxa::SaveTaxon.new(self).save_taxon(params, previous_combination)
  end

  # Deprecated: Many of the callers probably do not expect
  # that the first match is picked.
  def self.find_by_name name
    logger.info <<-MSG.squish
      AntCat: `Taxon.find_by_name` is deprecated. Use `Taxon.find_first_by_name`
      [not recommended] or `Taxon.where(name_cache:)` instead."
    MSG
    find_first_by_name name
  end

  def self.find_first_by_name name
    where(name_cache: name).first
  end

  def parent= id_or_object
    parent_taxon = id_or_object.kind_of?(Taxon) ? id_or_object : Taxon.find(id_or_object)
    # New taxa can have parents that are either in the "standard" rank progression (e.g.: Genus, species)
    # or they can be children of (subfamily) etc.
    if parent_taxon.is_a? Subgenus
      self.subgenus = parent_taxon
      self.genus = subgenus.parent
    else
      send Rank[self].parent.write_selector, parent_taxon
    end
  end

  def update_parent new_parent
    return if self.parent == new_parent
    self.name.change_parent new_parent.name
    set_name_caches
    self.parent = new_parent
    self.subfamily = new_parent.subfamily
  end

  def rank
    Rank[self].to_s
  end

  # The original_combination accessor returns the taxon with 'original combination'
  # status whose 'current valid taxon' points to us.
  def original_combination
    self.class.where(status: 'original combination', current_valid_taxon_id: id).first
  end

  # it "should provide a link if there's a valid hol_data entry"
  # it "should provide a link if there's one invalid hol_data entry"
  # it "should provide a link if there's one valid and one invalid hol_data entry"
  # it "should provide no link if there are two invalid entries"
  # it "should provide no link if there are two valid entries"
  def hol_id
    hol_data = HolTaxonDatum.where(antcat_taxon_id: id)

    valids, invalids = hol_data.partition(&:is_valid?)
    return valids.first.tnuid if valids.size == 1
    return invalids.first.tnuid if invalids.size == 1
  end

  # TODO: this triggers a save in the Name model for some reason.
  def authorship_string
    string = protonym.authorship_string
    if string && recombination?
      string = '(' + string + ')'
    end
    string
  end

end
