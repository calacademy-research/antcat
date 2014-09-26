# coding: UTF-8
require 'taxon_advanced_search'
require 'taxon_utility'
require 'taxon_workflow'

class Taxon < ActiveRecord::Base
  self.table_name = :taxa
  has_paper_trail

  include CleanNewlines
  before_save {|record| clean_newlines record, :headline_notes_taxt, :type_taxt}

  ###############################################
  # nested attributes
  belongs_to :name; validates :name, presence: true
  belongs_to :protonym, dependent: :destroy; validates :protonym, presence: true
  belongs_to :type_name, class_name: 'Name', foreign_key: :type_name_id
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
    column = name.split(' ').size > 1 ? 'name' : 'epithet'
    case search_type
    when 'matching'
      query = query.where ["names.#{column} = ?", name]
    when 'beginning with'
      query = query.where ["names.#{column} LIKE ?", name + '%']
    when 'containing'
      query = query.where ["names.#{column} LIKE ?", '%' + name + '%']
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

  def self.sort_by_status_and_name(taxa)
    taxa.sort do |a, b|
      if a.status == b.status
        # name ascending
        a.name.name <=> b.name.name
      else
        # status descending
        b.status <=> a.status
      end
    end
  end

  ###############################################
  # synonym
  def synonym?; status == 'synonym' end
  def junior_synonym_of? taxon; senior_synonyms.include? taxon end
  def senior_synonym_of? taxon; junior_synonyms.include? taxon end
  alias synonym_of? junior_synonym_of?
  has_many :synonyms_as_junior, foreign_key: :junior_synonym_id, class_name: 'Synonym'

  def junior_synonyms_with_names; synonyms_with_names :junior end
  def senior_synonyms_with_names; synonyms_with_names :senior end

  def synonyms_with_names junior_or_senior
    if junior_or_senior == :junior
      join_column = 'junior_synonym_id'
      where_column = 'senior_synonym_id'
    else
      join_column = 'senior_synonym_id'
      where_column = 'junior_synonym_id'
    end

    self.class.find_by_sql %{
      SELECT synonyms.id, taxa.name_html_cache AS name
      FROM synonyms JOIN taxa ON synonyms.#{join_column} = taxa.id
      JOIN names ON taxa.name_id = names.id
      WHERE #{where_column} = #{id}
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

  def become_not_junior_synonym_of senior
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
  # parent
  attr_accessor :parent_name
  def parent= id_or_object
    parent_taxon = id_or_object.kind_of?(Taxon) ? id_or_object : Taxon.find(id_or_object)
    send Rank[self].parent.write_selector, parent_taxon
  end

  def parent
    return nil if kind_of? Family
    return Family.first if kind_of? Subfamily
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
    raise NotImplementedError
  end

  def rank
    Rank[self].to_s
  end

  ###############################################
  # current_valid_taxon
  belongs_to  :current_valid_taxon, class_name: 'Taxon'
  attr_accessor :current_valid_taxon_name
  def current_valid_taxon_including_synonyms
    if synonym?
      if senior = find_most_recent_valid_senior_synonym
        return senior
      end
    end
    current_valid_taxon
  end
  def current_valid_taxon_including_synonyms_and_self
    current_valid_taxon_including_synonyms || self
  end
  def find_most_recent_valid_senior_synonym
    return unless senior_synonyms
    for senior_synonym in senior_synonyms.order('created_at DESC')
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
  def original_combination?;  status == 'original combination' end

  # The original_combination accessor returns the taxon with 'original combination'
  # status whose 'current valid taxon' points to us.
  def original_combination
    self.class.where(status: 'original combination', current_valid_taxon_id: id).first
  end

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
  def excluded_from_formicidae?; status == 'excluded from Formicidae' end
  def incertae_sedis_in? rank;incertae_sedis_in == rank end
  def collective_group_name?; status == 'collective group name' end
  def unidentifiable?;        status == 'unidentifiable' end
  def obsolete_combination?;  status == 'obsolete combination' end

  ###############################################
  def authorship_string
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
  before_validation :add_protocol_to_type_speciment_url
  validate :check_url

  def add_protocol_to_type_speciment_url
    self.type_specimen_url = "http://" + type_specimen_url if type_specimen_url.present? && type_specimen_url !~ %r{^http://}
  end

  def check_url
    return if type_specimen_url.blank?
    # a URL with spaces is valid, but URI.parse rejects it
    uri = URI.parse type_specimen_url.gsub(/ /, '%20')
    response_code = Net::HTTP.new(uri.host, 80).request_head(uri.request_uri).code.to_i
    errors.add :type_specimen_url, 'was not found' unless (200..399).include? response_code
  rescue SocketError, URI::InvalidURIError, ArgumentError
    errors.add :type_specimen_url, 'is not in a valid format'
  end

  ###############################################
  # statistics
  def get_statistics ranks
    statistics = {}
    ranks.each do |rank|
      count = send(rank).count :group => [:fossil, :status]
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
    children = children.where fossil: !!conditions[:fossil] if conditions.key? :fossil
    incertae_sedis_in = conditions[:incertae_sedis_in]
    children = children.where incertae_sedis_in: incertae_sedis_in if incertae_sedis_in
    children = children.where hong: !!conditions[:hong] if conditions.key? :hong
    children = children.where status: 'valid'
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
    [:subfamily_id, :tribe_id, :genus_id, :subgenus_id, :species_id, :homonym_replaced_by_id, :current_valid_taxon_id].each do |field|
      Taxon.where(field => id).each do |taxon|
        references << {table: 'taxa', field: field, id: taxon.id}
      end
    end
    references
  end

  def references_in_synonyms
    references = []
    synonyms_as_senior.each do |synonym|
      references << {table: 'synonyms', field: :senior_synonym_id, id: synonym.junior_synonym_id}
    end
    synonyms_as_junior.each do |synonym|
      references << {table: 'synonyms', field: :junior_synonym_id, id: synonym.senior_synonym_id}
    end
    references
  end

  def references_in_taxt
    references = []
    Taxt.taxt_fields.each do |klass, fields|
      for record in klass.send :all
        # don't include the taxt in this or child records
        next if klass == Taxon && record.id == id
        next if klass == Protonym && record.id == protonym_id
        if klass == Citation
          authorship_id = protonym.try(:authorship).try(:id)
          next if authorship_id == record.id
        end
        for field in fields
          next unless record[field]
          if record[field] =~ /{tax #{id}}/
            references << {table: klass.table_name, field: field, id: record[:id]}
          end
        end
      end
    end
    references
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

  def self.inherit_attributes_for_new_combination(new_combination, old_combination, new_combination_parent)
    if new_combination_parent.is_a? Species
      new_combination.name = Name.parse([ new_combination_parent.name.genus_epithet,
        new_combination_parent.name.species_epithet, old_combination.name.epithet ].join(' '))
    else
      new_combination.name = Name.parse([ new_combination_parent.name.genus_epithet,
        old_combination.name.species_epithet ].join(' '))
    end
    new_combination.protonym = old_combination.protonym
    new_combination.verbatim_type_locality = old_combination.verbatim_type_locality
    new_combination.biogeographic_region = old_combination.biogeographic_region
    new_combination.type_specimen_repository = old_combination.type_specimen_repository
    new_combination.type_specimen_code = old_combination.type_specimen_code
    new_combination.type_specimen_url = old_combination.type_specimen_url
  end

  def self.attributes_for_new_usage(new_combination, old_combination)
    {
      name_attributes: { id: new_combination.name ? new_combination.name.id : old_combination.name.id },
      status: 'valid',
      homonym_replaced_by_name_attributes: {
        id: old_combination.homonym_replaced_by ? old_combination.homonym_replaced_by.name_id : nil },
      current_valid_taxon_name_attributes: {
        id: old_combination.current_valid_taxon ? old_combination.current_valid_taxon.name_id : nil },
      incertae_sedis_in: old_combination.incertae_sedis_in,
      fossil: old_combination.fossil,
      nomen_nudum: old_combination.nomen_nudum,
      unresolved_homonym: old_combination.unresolved_homonym,
      ichnotaxon: old_combination.ichnotaxon,
      hong: old_combination.hong,
      headline_notes_taxt: old_combination.headline_notes_taxt || "",
      biogeographic_region: old_combination.biogeographic_region,
      verbatim_type_locality: old_combination.verbatim_type_locality,
      type_specimen_repository: old_combination.type_specimen_repository,
      type_specimen_code: old_combination.type_specimen_code,
      type_specimen_url: old_combination.type_specimen_url,
      protonym_attributes: {
        name_attributes: {
          id: old_combination.protonym.name_id },
        fossil: old_combination.protonym.fossil,
        sic: old_combination.protonym.sic,
        locality: old_combination.protonym.locality,
        id: old_combination.protonym_id,
        authorship_attributes: {
          reference_attributes: {
            id: old_combination.protonym.authorship.reference_id },
          pages: old_combination.protonym.authorship.pages,
          forms: old_combination.protonym.authorship.forms,
          notes_taxt: old_combination.protonym.authorship.notes_taxt || "",
          id: old_combination.protonym.authorship_id
        }
      }
    }
  end

  class TaxonExists < StandardError; end
end
