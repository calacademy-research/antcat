# coding: UTF-8
class Reference < ActiveRecord::Base
  # associations
  has_many    :reference_author_names, :order => :position
  has_many    :author_names, :through => :reference_author_names, :order => :position,
                :after_add => :refresh_author_names_caches, :after_remove => :refresh_author_names_caches
  belongs_to  :journal
  belongs_to  :publisher
  belongs_to  :source_reference, :polymorphic => true
  has_one     :document, :class_name => 'ReferenceDocument'
  accepts_nested_attributes_for :document, :reject_if => :all_blank

  # scopes
  scope :sorted_by_principal_author_last_name, order(:principal_author_last_name_cache)
  scope :with_principal_author_last_name, lambda {|last_name| where :principal_author_last_name_cache => last_name}

  # Solr
  searchable do
    text :title
    text :author_names_string
    text :journal_name do
      journal.name if journal
    end
    text :publisher_name do
      publisher.name if publisher
    end
    text :citation
    text :cite_code
    text :public_notes
    text :editor_notes
    text :taxonomic_notes
    string :author_names_string
    string :citation_year
    integer :year
  end

  # Other plugins and mixins
  has_paper_trail
  include ReferenceComparable; def author; principal_author_last_name; end
  include HasDocument

  # validation and callbacks
  before_validation :set_year, :strip_newlines
  before_save       :set_author_names_caches
  before_destroy    :check_that_is_not_nested
  validate          :check_for_duplicate
  validates_presence_of :year, :title

  # accessors
  def key
    @key ||= ReferenceKey.new(self)
  end
  def authors reload = false
    author_names(reload).map &:author
  end
  def author_names_string
    author_names_string_cache
  end
  def author_names_string= string
    self.author_names_string_cache = string
  end
  def principal_author_last_name
    principal_author_last_name_cache
  end

  # search
  def self.advanced_search parameters = {}
    author_names = AuthorParser.parse(parameters[:q])[:names]
    authors = Author.find_by_names author_names
    reference_ids = find_having_authors authors
    Reference.where('id IN (?)', reference_ids).order(:author_names_string_cache, :citation_year)
  end

  def self.find_having_authors authors
    Reference.select('`references`.*').
      joins(:author_names).
      joins('JOIN authors ON authors.id = author_names.author_id').
      where('authors.id IN (?)', authors).
      group('references.id').
      having("COUNT(`references`.id) = #{authors.length}")
  end

  def self.do_advanced_search options = {}
    paginate = options[:format] != :endnote_import
    results = advanced_search(options)
    paginate ? results.paginate(:page => options[:page]) : results
  end

  def self.do_search options = {}
    return do_advanced_search(options) if options[:advanced]

    paginate = options[:format] != :endnote_import

    return order('updated_at DESC').paginate :page => options[:page] if options[:review]
    return order('created_at DESC').paginate :page => options[:page] if options[:whats_new]

    unless options[:q].present?
      if paginate
        return order(:author_names_string_cache, :citation_year).paginate :page => options[:page]
      else
        return order :author_names_string_cache, :citation_year
      end
    end

    string = ActiveSupport::Inflector.transliterate options[:q].downcase

    only_show_unknown_references = false
    question_mark_index = string.index '?'
    if question_mark_index
      string[question_mark_index] = ''
      only_show_unknown_references = true
    end

    if match = string.match(/\d{5,}/)
      return where(:id => match[0]).paginate :page => 1
    end

    results = search {
      start_year, end_year = extract_years string
      if start_year
        if end_year
          with(:year).between(start_year..end_year)
        else
          with(:year).equal_to start_year
        end
      end
      keywords string
      order_by :author_names_string
      order_by :citation_year
      paginate(:page => options[:page]) if paginate
      paginate(:per_page => 5_000) if only_show_unknown_references
    }.results

    if only_show_unknown_references
      ids = results.map &:id
      return where(:type => 'UnknownReference').where('id' => ids).paginate(:page => options[:page])
    end

    results
  end

  ## callbacks

  # validation
  def check_for_duplicate
    duplicates = DuplicateMatcher.new.match self
    return unless duplicates.present?
    duplicate = Reference.find duplicates.first[:match]
    errors.add :base, "This seems to be a duplicate of #{ReferenceFormatter.format duplicate} #{duplicate.id}"
  end
  def check_that_is_not_nested
    nester = NestedReference.find_by_nested_reference_id id
    errors.add :base, "This reference can't be deleted because it's nested in #{nester}" if nester
    nester.nil?
  end

  # update
  def refresh_author_names_caches _ = nil
    string, principal_author_last_name = make_author_names_caches
    update_attribute :author_names_string_cache, string
    update_attribute :principal_author_last_name_cache, principal_author_last_name
  end
  def strip_newlines
    [:title, :public_notes, :editor_notes, :taxonomic_notes].each do |field|
      self[field].gsub! /\n/, ' ' if self[field].present?
    end
  end
  def set_year
    self.year = self.class.convert_citation_year_to_year citation_year
  end

  def self.convert_citation_year_to_year citation_year
    if citation_year.blank?
      nil
    elsif match = citation_year.match(/\["(\d{4})"\]/)
      match[1]
    else
      citation_year.to_i
    end
  end

  def to_s
    s = ''
    s << "#{author_names_string} "
    s << "#{citation_year}. "
    s << "#{id}."
    s
  end

  # AuthorNames
  def parse_author_names_and_suffix author_names_string
    author_names_and_suffix = AuthorName.import_author_names_string author_names_string.dup
    if author_names_and_suffix[:author_names].empty? && author_names_string.present?
      errors.add :author_names_string, "couldn't be parsed. Please post a message on http://groups.google.com/group/antcat/, and we'll fix it!"
      self.author_names_string = author_names_string
      raise ActiveRecord::RecordInvalid.new self
    end
    author_names_and_suffix
  end

  private
  def self.extract_years string
    start_year = end_year = nil
    if match = string.match(/\b(\d{4})-(\d{4}\b)/)
      start_year = match[1].to_i
      end_year = match[2].to_i
    elsif match = string.match(/(?:^|\s)(\d{4})\b/)
      start_year = match[1].to_i
    end

    return nil, nil unless (1758..(Time.now.year + 1)).include? start_year

    string.gsub! /#{match[0]}/, '' if match
    return start_year, end_year
  end

  def make_author_names_caches
    string = author_names.map(&:name).join('; ')
    string << author_names_suffix if author_names_suffix.present?
    first_author_name = author_names.first
    last_name = first_author_name && first_author_name.last_name
    return string, last_name
  end

  def set_author_names_caches(*)
    self.author_names_string_cache, self.principal_author_last_name_cache = make_author_names_caches
  end

  class DuplicateMatcher < ReferenceMatcher
    def min_similarity
      0.5
    end
  end

  class BoltonReferenceNotMatched < StandardError; end
  class BoltonReferenceNotFound < StandardError; end
end
