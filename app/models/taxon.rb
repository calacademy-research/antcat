# coding: UTF-8
class Taxon < ActiveRecord::Base
  self.table_name = :taxa

  has_paper_trail

  ###############################################
  # nested attributes
  belongs_to :name; validates :name, presence: true
  belongs_to :protonym, dependent: :destroy
  belongs_to  :type_name, class_name: 'Name', foreign_key: :type_name_id
  accepts_nested_attributes_for :name, :protonym, :type_name

  before_save :set_name_caches, :delete_synonyms
  def set_name_caches
    self.name_cache = name.name
    self.name_html_cache = name.name_html
  end
  def delete_synonyms
    return unless changes['status'].try(:first) == 'synonym'
    synonyms_as_junior.destroy_all if synonyms_as_junior.present?
  end

  ###############################################
  # name
  scope :with_names, joins(:name).readonly(false)
  scope :ordered_by_name, with_names.order('names.name').includes(:name)

  def self.find_by_name name
    where(name_cache: name).first
  end

  def self.find_all_by_name name
    where name_cache: name
  end

  def self.find_by_epithet epithet
    joins(:name).readonly(false).where ['epithet = ?', epithet]
  end

  def self.find_epithet_in_genus target_epithet, genus
    for epithet in Name.make_epithet_set target_epithet
      results = with_names.where(['genus_id = ? AND epithet = ?', genus.id, epithet])
      return results unless results.empty?
    end
    nil
  end

  def self.find_name name, search_type = 'matching'
    name = name.dup.strip
    query = ordered_by_name
    column = name.split(' ').size > 1 ?  'name' : 'epithet'
    types_sought = ['Subfamily', 'Tribe', 'Genus', 'Subgenus', 'Species', 'Subspecies']
    case search_type
    when 'matching'
      query = query.where ["names.#{column} = ?    AND taxa.type IN (?)", name, types_sought]
    when 'beginning with'
      query = query.where ["names.#{column} LIKE ? AND taxa.type IN (?)", name + '%', types_sought]
    when 'containing'
      query = query.where ["names.#{column} LIKE ? AND taxa.type IN (?)", '%' + name + '%', types_sought]
    end
    query.all
  end

  def self.find_by_name_and_authorship name, author_names, year, pages = nil
    bolton_key = Bolton::ReferenceKey.new(author_names.join(' '), year).to_s :db if author_names
    Progress.log "Name: #{name.name} Author names: #{author_names} year: #{year}, pages: #{pages} Bolton key: #{bolton_key}"
    Species; Subspecies
    if name.kind_of? SpeciesGroupName
      taxon = find_species_group_taxon_by_name_and_authorship name, bolton_key, pages
    else
      taxon = search_for_name_and_authorship name.name, bolton_key, pages
    end
    Progress.log "Not found" unless taxon
    taxon
  end

  def self.find_species_group_taxon_by_name_and_authorship name, bolton_key, pages
    name_parts = name.name.split ' '
    name_parts[2] ||= ''
    name_parts[3] ||= ''
    # elide subgenus
    if name_parts[1] =~ /\(.*?\)/
      name_parts[0] << ' ' << name_parts[1]
      name_parts[1..-2] = name_parts[2..-1]
    end
    for first_word in EpithetSearchSet.new(name_parts[1]).epithets
      for second_word in EpithetSearchSet.new(name_parts[2]).epithets
        for third_word in EpithetSearchSet.new(name_parts[3]).epithets
          name = name_parts[0] + ' ' + first_word + ' ' + second_word + ' ' + third_word
          name.strip!
          taxon = search_for_name_and_authorship name, bolton_key, pages
          return taxon if taxon
        end
      end
    end
    nil
  end

  def self.search_for_name_and_authorship name, bolton_key, pages = nil
    results = where name_cache: name
    if results.size > 1
      results = joins(protonym: [{authorship: :reference}]).where 'name_cache = ? AND references.bolton_key_cache = ?', name, bolton_key
      if results.size > 1 and pages
        results = results.to_a.select {|result| result.protonym.authorship.pages == pages}
        if results.size > 1
          raise 'Duplicate name + authorships'
        end
      end
    end
    return if results.size == 0
    Progress.log 'Found it'
    return find results.first.id
  end

  ###############################################
  # synonym
  def synonym?; status == 'synonym' end
  def junior_synonym_of? taxon; senior_synonyms.include? taxon end
  def senior_synonym_of? taxon; junior_synonyms.include? taxon end
  alias synonym_of? junior_synonym_of?
  has_many :synonyms_as_junior, foreign_key: :junior_synonym_id, class_name: 'Synonym'

  def junior_synonyms_with_names
    self.class.find_by_sql %{
      SELECT synonyms.id, taxa.name_html_cache AS name
      FROM synonyms JOIN taxa ON synonyms.junior_synonym_id = taxa.id
      JOIN names ON taxa.name_id = names.id
      WHERE senior_synonym_id = #{id}
      ORDER BY name
    }
  end

  def senior_synonyms_with_names
    self.class.find_by_sql %{
      SELECT synonyms.id, taxa.name_html_cache AS name
      FROM synonyms JOIN taxa ON synonyms.senior_synonym_id = taxa.id
      JOIN names ON taxa.name_id = names.id
      WHERE junior_synonym_id = #{id}
      ORDER BY name
    }
  end

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

  def become_not_a_junior_synonym_of senior
    Synonym.where('junior_synonym_id = ? AND senior_synonym_id = ?', id, senior).destroy_all
    update_attributes! status: 'valid' if senior_synonyms.empty?
  end

  ###############################################
  # homonym
  belongs_to  :homonym_replaced_by, class_name: 'Taxon'
  has_one     :homonym_replaced, class_name: 'Taxon', foreign_key: :homonym_replaced_by_id
  def homonym?; status == 'homonym' end
  def homonym_replaced_by? taxon; homonym_replaced_by == taxon end
  attr_accessor :homonym_replaced_by_name

  ###############################################
  # other associations
  has_many    :history_items, class_name: 'TaxonHistoryItem', order: :position, dependent: :destroy
  has_many    :reference_sections, order: :position, dependent: :destroy

  ###############################################
  # statuses, fossil
  scope :valid,               where(status: 'valid')
  scope :extant,              where(fossil: false)
  def unavailable?;           status == 'unavailable' end
  def available?;             !unavailable? end
  def invalid?;               status != 'valid' end
  def ichnotaxon?;            status == 'ichnotaxon' end
  def excluded?;              status == 'excluded' end
  def incertae_sedis_in?      rank; incertae_sedis_in == rank end
  def collective_group_name?; status == 'collective group name' end
  def nomen_nudum?;           status == 'nomen nudum' end

  ###############################################
  # delegations
  def authorship_string
    return unless protonym
    string = protonym.authorship_string
    if (kind_of?(Species) || kind_of?(Subspecies)) && name != protonym.name
      string = '(' + string + ')'
    end
    string
  end

  ###############################################
  def rank
    Rank[self].to_s
  end

  def children
    raise NotImplementedError
  end

  ###############################################
  # statistics

  def get_statistics ranks
    statistics = {}
    ranks.each do |rank|
      count = send(rank).count :group => [:fossil, :status]
      self.class.massage_count count, rank, statistics
    end
    statistics
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
    children = children.where fossil: !!conditions[:fossil] if conditions.key? :fossil
    incertae_sedis_in = conditions[:incertae_sedis_in]
    children = children.where incertae_sedis_in: incertae_sedis_in if incertae_sedis_in
    children = children.where hong: !!conditions[:hong] if conditions.key? :hong
    children = children.where status: 'valid'
    children = children.ordered_by_name
    children
  end


  ###############################################
  # import

  def import_synonyms senior
    return unless senior
    Synonym.find_or_create self, senior
  end

  def self.get_type_attributes data
    key = get_type_key
    attributes = {}
    if data[key]
      attributes[:type_name] = Name.import data[key]
      attributes[:type_fossil] = data[key][:fossil]
      attributes[:type_taxt] = Importers::Bolton::Catalog::TextToTaxt.convert data[key][:texts]
    end
    attributes
  end

  def import_history history
    history.each do |item|
      history_items.create! taxt: item
    end
  end

  def self.import_name data
    Name.import data
  end

  ###############################################
  def would_be_homonym_if_name_changed_to? name
    Taxon.where('name_cache = ? AND id != ?', name.name, id).count != 0
  end
end
