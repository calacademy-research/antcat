# coding: UTF-8
require 'reference_has_document'
require 'reference_search'
require 'reference_utility'
require 'reference_workflow'

class Reference < ActiveRecord::Base
  attr_accessor :publisher_string
  attr_accessor :journal_name
  has_paper_trail

  include CleanNewlines
  before_save {|record| clean_newlines record, :editor_notes, :public_notes, :taxonomic_notes, :title, :citation}

  # associations
  has_many    :reference_author_names, :order => :position
  has_many    :author_names, :through => :reference_author_names, :order => :position,
                :after_add => :refresh_author_names_caches, :after_remove => :refresh_author_names_caches
  belongs_to  :journal
  belongs_to  :publisher

  # scopes
  scope :sorted_by_principal_author_last_name, order(:principal_author_last_name_cache)
  scope :with_principal_author_last_name, lambda {|last_name| where :principal_author_last_name_cache => last_name}
  scope :non_missing, where('type IS NULL OR type != "MissingReference"')

  # Other plugins and mixins
  include ReferenceComparable; def author; principal_author_last_name; end

  # validation and callbacks
  before_validation :set_year_from_citation_year, :strip_text_fields
  validates         :title, presence: true, if: Proc.new {|record| record.class.requires_title}
  def self.requires_title; true end
  before_save       :set_author_names_caches
  before_destroy    :check_not_nested

  # accessors
  def to_s()                        "#{author_names_string} #{citation_year}. #{id}." end
  def key()                         @key ||= ReferenceKey.new(self) end
  def authors(reload = false)       author_names(reload).map &:author end
  def author_names_string()         author_names_string_cache end
  def author_names_string=(string)  self.author_names_string_cache = string end
  def principal_author_last_name()  principal_author_last_name_cache end

  def short_citation_year
    citation_year.gsub %r{ .*$}, ''
  end

  ## callbacks

  # validation
  def check_not_nested
    nester = NestedReference.find_by_nested_reference_id id
    errors.add :base, "This reference can't be deleted because it's nested in #{nester}" if nester
    nester.nil?
  end

  # update (including observed updates)
  def refresh_author_names_caches(*)
    string, principal_author_last_name = make_author_names_caches
    update_attribute :author_names_string_cache, string
    update_attribute :principal_author_last_name_cache, principal_author_last_name
  end

  ## utility
  # Called by controller to parse an input string for author names and suffix
  # Returns hash of parse result, or adds to the reference's errors and raises
  def parse_author_names_and_suffix author_names_string
    author_names_and_suffix = AuthorName.import_author_names_string author_names_string.dup
    if author_names_and_suffix[:author_names].empty? && author_names_string.present?
      errors.add :author_names_string, "couldn't be parsed. Please post a message on http://groups.google.com/group/antcat/, and we'll fix it!"
      self.author_names_string = author_names_string
      raise ActiveRecord::RecordInvalid.new self
    end
    author_names_and_suffix
  end
  def check_for_duplicate
    duplicates = DuplicateMatcher.new.match self
    return unless duplicates.present?
    duplicate = Reference.find duplicates.first[:match]
    errors.add :base, "This may be a duplicate of #{Formatters::ReferenceFormatter.format duplicate} #{duplicate.id}.<br>To save, click \"Save Anyway\"".html_safe
    true
  end
  def self.citation_year_to_year citation_year
    if citation_year.blank?
      nil
    elsif match = citation_year.match(/\["(\d{4})"\]/)
      match[1]
    else
      citation_year.to_i
    end
  end
  def to_class suffix = '', prefix = ''
    class_name = self.class.name
    raise "Don't know what kind of reference this is: #{inspect}" unless
      ['Article', 'Book', 'Nested', 'Unknown', 'Missing'].map {|e| e + 'Reference'}.include? class_name
    class_name = prefix + class_name + suffix
    class_name.constantize
  end

  ###############################################
  def references options = {}
    references = []
    #references.concat references_in_taxa
    #references.concat references_in_taxt unless options[:omit_taxt]
    #references.concat references_in_synonyms
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
  private
  def strip_text_fields
    [:title, :public_notes, :editor_notes, :taxonomic_notes, :citation].each do |field|
      value = self[field]
      next unless value.present?
      value.gsub! /(\n|\r|\n\r|\r\n)/, ' '
      value.strip!
      value.squeeze! ' '
      self[field] = value
    end
  end

  def set_year_from_citation_year
    self.year = self.class.citation_year_to_year citation_year
  end

  # author names caches
  def set_author_names_caches(*)
    self.author_names_string_cache, self.principal_author_last_name_cache = make_author_names_caches
  end
  def make_author_names_caches
    string = author_names.map(&:name).join('; ')
    string << author_names_suffix if author_names_suffix.present?
    first_author_name = author_names.first
    last_name = first_author_name && first_author_name.last_name
    return string, last_name
  end

  class DuplicateMatcher < ReferenceMatcher
    def min_similarity
      0.5
    end
  end

end
