# coding: UTF-8
class Reference < ActiveRecord::Base
  include ReferenceComparable
  has_paper_trail

  has_many :reference_author_names, :order => :position
  has_many :author_names, :through => :reference_author_names, :order => :position,
           :after_add => :update_author_names_caches, :after_remove => :update_author_names_caches
  has_many :duplicate_references, :order => 'similarity DESC'
  has_many :duplicates, :through => :duplicate_references
  belongs_to :journal
  belongs_to :publisher
  belongs_to :source_reference, :polymorphic => true
  has_one :document, :class_name => 'ReferenceDocument'
  accepts_nested_attributes_for :document, :reject_if => :all_blank

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

  before_validation :set_year, :strip_newlines
  before_save :set_author_names_caches
  before_destroy :check_that_is_not_nested

  validate :check_for_duplicate
  validates_presence_of :year, :title

  scope :sorted_by_author_name, select('`references`.*').joins(:author_names).where('position = 1').order(:name)
  scope :with_principal_author_last_name, lambda {|last_name| where :principal_author_last_name_cache => last_name}

  def authors reload = false
    author_names(reload).map(&:author)
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

  def self.advanced_search parameters = {}
    author_names = parameters[:q].dup
    author_names = AuthorParser.parse(author_names)[:names]
    reference_ids = Reference.select('`references`.*').
              joins(:author_names).
              where('name IN (?)', author_names).
              group('references.id').
              having("COUNT(`references`.id) = #{author_names.length}")
    Reference.where('id IN (?)', reference_ids).order(:author_names_string_cache, :citation_year)
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

    string = options[:q].dup

    if match = string.match(/\d{5,}/)
      return where(:id => match[0]).paginate :page => 1
    end

    search {
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
    }.results
  end

  def check_for_duplicate
    duplicates = DuplicateMatcher.new.match self
    return unless duplicates.present?
    duplicate = Reference.find duplicates.first[:match]
    errors.add :base, "This seems to be a duplicate of #{ReferenceFormatter.format duplicate} #{duplicate.id}"
  end

  def self.find_duplicate data
    possible_duplicates = Reference.where :title => data[:title], :year => get_year(data[:citation_year])
    possible_duplicates.find do |possible_duplicate|
      data[:author_names] == possible_duplicate.author_names.map(&:name)
    end
  end

  def self.get_year citation_year
    if citation_year.blank?
      nil
    elsif match = citation_year.match(/\["(\d{4})"\]/)
      match[1]
    else
      citation_year.to_i
    end
  end

  def self.import_hol_document_urls show_progress = false
    Hol::DocumentUrlImporter.new(show_progress).import
  end

  def update_author_names_caches _ = nil
    string, principal_author_last_name = make_author_names_caches
    update_attribute :author_names_string_cache, string
    update_attribute :principal_author_last_name_cache, principal_author_last_name
  end


  def replace_author_name old_name, new_author_name
    old_author_name = AuthorName.find_by_name old_name
    reference_author_name = reference_author_names.where(:author_name_id => old_author_name).first
    reference_author_name.author_name = new_author_name
    reference_author_name.save!
    author_names(true)
    update_author_names_caches
  end

  def url
    document && document.url
  end

  def downloadable_by? user
    document && document.downloadable_by?(user)
  end

  def document_host= host
    document && document.host = host
  end

  # ReferenceComparable
  def author; principal_author_last_name; end

  def to_s
    s = ''
    s << "#{author_names_string} "
    s << "#{citation_year}. "
    s << "#{id}."
    s
  end

  def check_that_is_not_nested
    nester = NestedReference.find_by_nested_reference_id id
    errors.add :base, "This reference can't be deleted because it's nested in #{nester}" if nester
    nester.nil?
  end

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
    if match = string.match(/(\b\d{4})-(\d{4}\b)/)
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

  def set_year
    self.year = self.class.get_year citation_year
  end

  def strip_newlines
    [:title, :public_notes, :editor_notes, :taxonomic_notes].each do |field|
      self[field].gsub! /\n/, ' ' if self[field].present?
    end
  end

  class DuplicateMatcher < ReferenceMatcher
    def min_similarity
      0.5
    end
  end

end
