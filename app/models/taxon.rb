# coding: UTF-8
class Taxon < ActiveRecord::Base

  set_table_name :taxa

  before_save :set_name_caches

  def set_name_caches
    self.name_cache = name.name
    self.name_html_cache = name.name_html
  end

  ###############################################
  # name
  belongs_to :name; validates :name, presence: true
  scope :with_names, joins(:name).readonly(false)
  scope :ordered_by_name, with_names.order('names.name').includes(:name)

  def self.find_by_name name
    where(['name_cache = ?', name]).first
  end

  def self.find_all_by_name name
    where ['name_cache = ?', name]
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
    Progress.log "Name: #{name.name} Author names: #{author_names} year: #{year}, pages: #{pages}"
    bolton_key = Bolton::ReferenceKey.new(author_names.join(' '), year).to_s :db if author_names
    Progress.log "Bolton key: #{bolton_key}"

    found_taxon = nil
    Species; Subspecies
    if name.kind_of? SpeciesGroupName
      name_parts = name.name.split ' '
      name_parts[2] ||= ''
      name_parts[3] ||= ''
      if name_parts[1] =~ /\(.*?\)/
        name_parts[0] << ' ' << name_parts[1]
        name_parts[1..-2] = name_parts[2..-1]
      end
      for first_word in EpithetSearchSet.new(name_parts[1]).epithets
        for second_word in EpithetSearchSet.new(name_parts[2]).epithets
          for third_word in EpithetSearchSet.new(name_parts[3]).epithets
            name = name_parts[0] + ' ' + first_word + ' ' + second_word + ' ' + third_word
            name.strip!
            found_taxon = do_search(name, bolton_key, pages)
            return found_taxon if found_taxon
          end
        end
      end
    else
      found_taxon = do_search(name.name, bolton_key, pages)
    end
    Progress.log "Not found" unless found_taxon
    found_taxon
  end

  def self.do_search name, bolton_key, pages
    results = where name_cache: name
    return if results.size == 0
    if results.size > 1
      results = joins(protonym: [{authorship: :reference}]).where 'name_cache = ? AND references.bolton_key_cache = ?', name, bolton_key
      return if results.size == 0
      if results.size > 1
        results = results.to_a.select {|result| result.protonym.authorship.pages == pages}
        return if results.size == 0
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
  has_many :synonyms_as_senior, foreign_key: :senior_synonym_id, class_name: 'Synonym'
  has_many :junior_synonyms, through: :synonyms_as_senior
  has_many :senior_synonyms, through: :synonyms_as_junior

  def become_junior_synonym_of senior
    Synonym.where(junior_synonym_id: senior, senior_synonym_id: self).destroy_all
    Synonym.where(senior_synonym_id: senior, junior_synonym_id: self).destroy_all
    Synonym.create! junior_synonym: self, senior_synonym: senior
    senior.update_attribute :status, 'valid'
    update_attribute :status, 'synonym'
  end

  def become_not_a_junior_synonym_of senior
    Synonym.where('junior_synonym_id = ? AND senior_synonym_id = ?', id, senior).destroy_all
    update_attribute :status, 'valid' if senior_synonyms.empty?
  end

  ###############################################
  # homonym
  belongs_to  :homonym_replaced_by, class_name: 'Taxon'
  has_one     :homonym_replaced, class_name: 'Taxon', foreign_key: :homonym_replaced_by_id
  def homonym?; status == 'homonym' end
  def homonym_replaced_by? taxon; homonym_replaced_by == taxon end

  ###############################################
  # other associations
  belongs_to  :protonym, dependent: :destroy
  belongs_to  :type_name, class_name: 'Name', foreign_key: :type_name_id
  has_many    :history_items, class_name: 'TaxonHistoryItem', order: :position, dependent: :destroy
  has_many    :reference_sections, order: :position, dependent: :destroy

  ###############################################
  # statuses, fossil
  scope :valid,               where(status: 'valid')
  scope :extant,              where(fossil: false)
  def unavailable?;           status == 'unavailable' end
  def available?;             !unavailable? end
  def invalid?;               status != 'valid' end
  def unidentifiable?;        status == 'unidentifiable' end
  def ichnotaxon?;            status == 'ichnotaxon' end
  def unresolved_homonym?;    status == 'unresolved homonym' end
  def excluded?;              status == 'excluded' end
  def incertae_sedis_in?      rank; incertae_sedis_in == rank end
  def collective_group_name?; status == 'collective group name' end

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
    children = children.where "status = 'valid' OR status = 'unresolved homonym'"
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

end
