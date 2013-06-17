# coding: UTF-8
require 'reference_search'
require 'reference_utility'
require 'reference_has_document'

class Reference < ActiveRecord::Base
  attr_accessor :publisher_string
  attr_accessor :journal_name

  has_paper_trail

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
  validates_presence_of :title
  before_save       :set_author_names_caches
  before_destroy    :check_not_nested

  # accessors
  def to_s()                        "#{author_names_string} #{citation_year}. #{id}." end
  def key()                         @key ||= ReferenceKey.new(self) end
  def authors(reload = false)       author_names(reload).map &:author end
  def author_names_string()         author_names_string_cache end
  def author_names_string=(string)  self.author_names_string_cache = string end
  def principal_author_last_name()  principal_author_last_name_cache end
  def being_reviewed?()             ReviewStatus[review_status].being_reviewed? end

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
