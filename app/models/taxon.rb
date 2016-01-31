require_dependency 'taxon_workflow'

class Taxon < ActiveRecord::Base
  include UndoTracker
  include Taxa::CallbacksAndValidators

  class TaxonExists < StandardError; end

  self.table_name = :taxa
  has_paper_trail meta: { change_id: :get_current_change_id }
  attr_accessor :authorship_string, :duplicate_type
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

  scope :displayable, -> { where(display: true) }

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
  belongs_to :name
  belongs_to :protonym, -> { includes :authorship }
  belongs_to :type_name, class_name: 'Name', foreign_key: :type_name_id

  has_many :taxa, class_name: "Taxon", foreign_key: :genus_id
  belongs_to :genus, class_name: 'Taxon'

  accepts_nested_attributes_for :name, :protonym, :type_name

  ###############################################
  # name
  scope :with_names, -> { joins(:name).readonly(false) }

  scope :ordered_by_name, lambda { with_names.order('names.name').includes(:name) }

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
  def synonym?
    status == 'synonym'
  end

  def junior_synonym_of? taxon
    senior_synonyms.include? taxon
  end

  def senior_synonym_of? taxon
    junior_synonyms.include? taxon
  end

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

  alias synonym_of? junior_synonym_of?
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
  belongs_to :homonym_replaced_by, class_name: 'Taxon'
  has_one :homonym_replaced, class_name: 'Taxon', foreign_key: :homonym_replaced_by_id

  def homonym?
    status == 'homonym'
  end

  def homonym_replaced_by? taxon
    homonym_replaced_by == taxon
  end

  attr_accessor :homonym_replaced_by_name

  ###############################################
  # parent
  attr_accessor :parent_name

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

  def children
    if Rank[self] == Rank[:subspecies]
      return []
    end
    raise NotImplementedError
  end

  def rank
    Rank[self].to_s
  end

  ###############################################
  # current_valid_taxon
  belongs_to :current_valid_taxon, class_name: 'Taxon'
  attr_accessor :current_valid_taxon_name

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

  ###############################################
  # original combination
  # A status of 'original combination' means that the taxon/name is a placeholder
  # for the original name of the species under the original genus.
  # The original_combination? predicate checks that.
  def original_combination?
    status == 'original combination'
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
  scope :valid, -> { where(status: 'valid') }
  scope :extant, -> { where(fossil: false) }

  def unavailable?
    status == 'unavailable'
  end

  def available?
    !unavailable?
  end

  def invalid?
    status != 'valid'
  end

  def excluded_from_formicidae?
    status == 'excluded from Formicidae'
  end

  def incertae_sedis_in? rank
    incertae_sedis_in == rank
  end

  def collective_group_name?
    status == 'collective group name'
  end

  def unidentifiable?
    status == 'unidentifiable'
  end

  def obsolete_combination?
    status == 'obsolete combination'
  end

  def unavailable_misspelling?
    status == 'unavailable misspelling'
  end

  def unavailable_uncategorized?
    status == 'unavailable uncategorized'
  end

  def nonconfirming_synonym?
    status == 'nonconforming synonym'
  end

  ###############################################
  def authorship_string
    # TODO: this triggers a save in the Name model for some reason.
    string = protonym.authorship_string
    if string && recombination?
      string = '(' + string + ')'
    end
    string
  end

  def authorship_html_string
    protonym.authorship_html_string
  end

  def author_last_names_string
    protonym.author_last_names_string
  end

  def year
    protonym.year
  end

  def recombination?
    false
  end

  ###############################################
  # statistics
  def get_statistics ranks
    statistics = {}
    ranks.each do |rank|
      count = send(rank).group('fossil', 'status').count
      delete_original_combinations count
      self.class.massage_count count, rank, statistics
    end
    statistics
  end

  def delete_original_combinations count
    count.delete [true, 'original combination']
    count.delete [false, 'original combination']
  end

  def self.massage_count count, rank, statistics
    count.keys.each do |fossil, status|
      value = count[[fossil, status]]
      extant_or_fossil = fossil ? :fossil : :extant
      statistics[extant_or_fossil] ||= {}
      statistics[extant_or_fossil][rank] ||= {}
      statistics[extant_or_fossil][rank][status] = value
    end
  end

  def child_list_query children_selector, conditions = {}
    children = send children_selector
    children = children.where(fossil: !!conditions[:fossil]) if conditions.key? :fossil
    incertae_sedis_in = conditions[:incertae_sedis_in]
    children = children.where(incertae_sedis_in: incertae_sedis_in) if incertae_sedis_in
    children = children.where(hong: !!conditions[:hong]) if conditions.key? :hong
    children = children.where(status: 'valid')
    children = children.ordered_by_name
    children
  end

  ###############################################
  def references options = {}
    references = []
    references.concat references_in_taxa
    references.concat references_in_taxt unless options[:omit_taxt]
    references.concat references_in_synonyms
  end

  def nontaxt_references
    references omit_taxt: true
  end

  def references_in_taxa
    references = []
    [:subfamily_id, :tribe_id, :genus_id, :subgenus_id,:species_id,
     :homonym_replaced_by_id, :current_valid_taxon_id].each do |field|
      Taxon.where(field => id).each do |taxon|
        references << { table: 'taxa', field: field, id: taxon.id }
      end
    end
    references
  end

  def references_in_synonyms
    references = []
    synonyms_as_senior.each do |synonym|
      references << { table: 'synonyms', field: :senior_synonym_id, id: synonym.junior_synonym_id }
    end
    synonyms_as_junior.each do |synonym|
      references << { table: 'synonyms', field: :junior_synonym_id, id: synonym.senior_synonym_id }
    end
    references
  end

  def references_in_taxt
    references = []
    Taxt.taxt_fields.each do |klass, fields|
      klass.send(:all).each do |record|
        # don't include the taxt in this or child records
        next if klass == Taxon && record.id == id
        next if klass == Protonym && record.id == protonym_id
        if klass == Citation
          authorship_id = protonym.try(:authorship).try(:id)
          next if authorship_id == record.id
        end
        fields.each do |field|
          next unless record[field]
          if record[field] =~ /{tax #{id}}/
            references << { table: klass.table_name, field: field, id: record[:id] }
          end
        end
      end
    end
    references
  end

end
