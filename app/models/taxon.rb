require_dependency 'taxon_workflow'

class Taxon < ActiveRecord::Base
  include UndoTracker
  include Taxa::CallbacksAndValidators
  include Taxa::PredicateMethods
  include Taxa::Statistics
  include Taxa::References

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

  scope :displayable, -> { where(display: true) }
  scope :valid, -> { where(status: 'valid') }
  scope :extant, -> { where(fossil: false) }
  scope :with_names, -> { joins(:name).readonly(false) }
  scope :ordered_by_name, lambda { with_names.order('names.name').includes(:name) }

  def save_taxon params, previous_combination = nil
    Taxa::SaveTaxon.new(self).save_taxon(params, previous_combination)
  end

  def delete_impact_list
    Taxa::Utility.new(self).delete_impact_list
  end

  def delete_taxon_and_children
    Taxa::Utility.new(self).delete_taxon_and_children
  end

  def delete_with_state!
    Taxon.transaction do
      taxon_state = self.taxon_state
      # Bit of a hack; this is a new table which may lack the depth of other tables.
      # Creation doesn't add a record, so you can't "step back to" a valid version.
      # doing touch_with_version (creeate a fallback point) in the migration makes an
      # enourmous and unnecessary pile of these.
      if taxon_state.versions.empty?
        taxon_state.touch_with_version
      end

      taxon_state.deleted = true
      taxon_state.review_state = 'waiting'
      taxon_state.save
      destroy!
    end
  end

  ###############################################
  # nested attributes

  has_many :taxa, class_name: "Taxon", foreign_key: :genus_id


  accepts_nested_attributes_for :name, :protonym, :type_name

  ###############################################
  # name
  def self.find_by_name name
    where(name_cache: name).first
  end

  def self.find_all_by_name name
    where(name_cache: name)
  end

  def self.find_by_epithet epithet
    joins(:name).readonly(false).where ['epithet = ?', epithet]
  end

  # target_epithet is a string
  # genus is an object
  def self.find_epithet_in_genus target_epithet, genus
    Name.make_epithet_set(target_epithet).each do |epithet|
      results = with_names.where(['genus_id = ? AND epithet = ?', genus.id, epithet])
      return results unless results.empty?
    end
    nil
  end

  def self.find_subspecies_in_genus target_subspecies, genus
    Name.make_epithet_set(target_subspecies).each do |epithet|
      results = with_names.where(['genus_id = ? AND epithet = ?', genus.id, epithet])
      return results unless results.empty?
    end
    nil
  end

  ###############################################
  # synonym
  def junior_synonyms_with_names
    synonyms_with_names :junior
  end

  def senior_synonyms_with_names
    synonyms_with_names :senior
  end

  def synonyms_with_names junior_or_senior
    if junior_or_senior == :junior
      join_column = 'junior_synonym_id'
      where_column = 'senior_synonym_id'
    else
      join_column = 'senior_synonym_id'
      where_column = 'junior_synonym_id'
    end

    self.class.find_by_sql <<-SQL.squish
      SELECT synonyms.id, taxa.name_html_cache AS name
      FROM synonyms JOIN taxa ON synonyms.#{join_column} = taxa.id
      JOIN names ON taxa.name_id = names.id
      WHERE #{where_column} = #{id}
      ORDER BY name
    SQL
  end

  has_many :synonyms_as_junior, foreign_key: :junior_synonym_id, class_name: 'Synonym'
  has_many :synonyms_as_senior, foreign_key: :senior_synonym_id, class_name: 'Synonym'
  has_many :junior_synonyms, through: :synonyms_as_senior
  has_many :senior_synonyms, through: :synonyms_as_junior

  def become_junior_synonym_of senior
    Synonym.where(junior_synonym_id: senior, senior_synonym_id: self).destroy_all
    Synonym.where(senior_synonym_id: senior, junior_synonym_id: self).destroy_all
    Synonym.create! junior_synonym: self, senior_synonym: senior
    senior.update_attributes! status: 'valid'
    update_attributes! status: 'synonym'
  end

  def become_not_junior_synonym_of senior
    Synonym.where('junior_synonym_id = ? AND senior_synonym_id = ?', id, senior).destroy_all
    update_attributes! status: 'valid' if senior_synonyms.empty?
  end

  ###############################################
  # homonym
  has_one :homonym_replaced, class_name: 'Taxon', foreign_key: :homonym_replaced_by_id

  ###############################################
  # parent

  def parent= id_or_object
    parent_taxon = id_or_object.kind_of?(Taxon) ? id_or_object : Taxon.find(id_or_object)
    #
    # New taxa can have parents that are either in the "standard" rank progression (e.g.: Genus, species)
    # or they can be children of (subfamily) etc.
    #

    if parent_taxon.is_a? Subgenus
      self.subgenus = parent_taxon
      self.genus = subgenus.parent
    else
      send Rank[self].parent.write_selector, parent_taxon
    end
  end

  def parent
    return nil if kind_of? Family
    return Family.first if kind_of? Subfamily
    if self.subgenus_id
      return subgenus
    end
    send Rank[self].parent.read_selector
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

  ###############################################
  # current_valid_taxon

  def current_valid_taxon_including_synonyms
    if synonym?
      if senior = find_most_recent_valid_senior_synonym
        return senior
      end
    end
    current_valid_taxon
  end

  def find_most_recent_valid_senior_synonym
    return unless senior_synonyms
    senior_synonyms.order('created_at DESC').each do |senior_synonym|
      return senior_synonym if !senior_synonym.invalid?
      return nil unless senior_synonym.synonym?
      return senior_synonym.find_most_recent_valid_senior_synonym
    end
    nil
  end

  # The original_combination accessor returns the taxon with 'original combination'
  # status whose 'current valid taxon' points to us.
  def original_combination
    self.class.where(status: 'original combination', current_valid_taxon_id: id).first
  end

  ###############################################
  # other associations
  has_many :history_items, -> { order 'position' }, class_name: 'TaxonHistoryItem', dependent: :destroy
  has_many :reference_sections, -> { order 'position' }, dependent: :destroy

  # TODO: joe This is hit four times on main page load. Why
  # we have one valid entry
  # it "should provide a link if there's a valid hol_data entry"
  # it "should provide a link if there's one invalid hol_data entry"
  # it "should provide a link if there's one valid and one invalid hol_data entry"
  # it "should provide no link if there are two invalid entries"
  # it "should provide no link if there are two valid entries"
  def hol_id
    hd = HolTaxonDatum.where(antcat_taxon_id: id)

    valid_hd = nil
    valid_count = 0
    hd.each do |is_valid|
      if is_valid['is_valid'].downcase == 'valid'
        valid_count = valid_count + 1
        valid_hd = is_valid
      end
    end

    if (hd.count != 1 && valid_hd.nil?) || valid_count > 1
      # If we get more than one hit and we don't have a "valid" entry, then we can't tell
      # which link to return. That's bad, so return nothing.
      return nil
    end

    if valid_hd.nil?
      hd[0].tnuid
    else
      valid_hd.tnuid
    end
  end

  ###############################################
  # statuses, fossil

  ###############################################
  def authorship_string
    # TODO: this triggers a save in the Name model for some reason.
    string = protonym.authorship_string
    if string && recombination?
      string = '(' + string + ')'
    end
    string
  end

end
