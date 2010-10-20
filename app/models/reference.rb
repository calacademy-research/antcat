class Reference < ActiveRecord::Base
  has_many :author_participations, :order => :position
  has_many :authors, :through => :author_participations, :order => :position,
           :after_add => :update_authors_string, :after_remove => :update_authors_string
  belongs_to :journal
  belongs_to :source_reference, :polymorphic => true

  before_validation :set_year, :strip_newlines, :set_source_url

  validates_presence_of :authors, :year, :title

  named_scope :sorted_by_author, 
    :select => '`references`.*',
    :joins => 'JOIN author_participations ON reference_id = `references`.id JOIN authors ON author_id = authors.id',
    :conditions => 'author_participations.position = 1',
    :order => 'name ASC'

  def self.import data
    create_data = {
      :authors => Author.import(data[:authors]),
      :citation_year => data[:citation_year],
      :title => data[:title],
      :cite_code => data[:cite_code],
      :possess => data[:possess],
      :date => data[:date],
      :public_notes => data[:public_notes],
      :taxonomic_notes => data[:taxonomic_notes],
      :editor_notes => data[:editor_notes],
      :source_reference_id => data[:id],
      :source_reference_type => data[:class], 
    }
    case
    when data[:book]
      BookReference.import create_data, data[:book]
    when data[:article]
      ArticleReference.import create_data, data[:article]
    when data[:other]
      OtherReference.import create_data, data[:other]
    end
  rescue
    puts data
    raise
  end

  def self.search terms = {}
    conditions = []
    conditions_arguments = {}
    joins = []

    if terms[:author].present?
      conditions << 'authors.name LIKE :author'
      conditions_arguments[:author] = "#{terms[:author]}%"
      joins << :authors
    end

    if terms[:journal].present?
      conditions << 'journals.title LIKE :journal'
      conditions_arguments[:journal] = terms[:journal]
      joins << :journal
    end

    if terms[:start_year].present?
      conditions << 'year >= :start_year'
      conditions_arguments[:start_year] = terms[:start_year]
    end

    if terms[:end_year].present?
      conditions << 'year <= :end_year'
      conditions_arguments[:end_year] = terms[:end_year]
    end

    all :joins => joins, :conditions => [conditions.join(' AND '), conditions_arguments],
        :order => 'authors_string, citation_year'
  end

  def citation_string
  end

  def update_authors_string _ = nil
    update_attribute :authors_string, authors.map(&:name).join('; ')
  end

  def self.add_period_if_necessary string
    return unless string
    return string if string.empty?
    return string + '.' unless string[-1..-1] == '.'
    string
  end

  def set_year
    self.year = if citation_year.blank?
      nil
    elsif match = citation_year.match(/\["(\d{4})"\]/)
      match[1]
    else
      citation_year.to_i 
    end
  end

  def strip_newlines
    [:title, :public_notes, :editor_notes, :taxonomic_notes].each do |field|
      self[field].gsub! /\n/, ' ' if self[field].present?
    end
  end

  def self.import_hol_source_urls show_progress = false
    HolSourceUrlImporter.new(show_progress).import
  end

  def to_s
    s = ''
    s << "#{authors_string} "
    s << "#{citation_year}. "
    s << "#{id}."
    s
  end

  def set_source_url
    self.source_url = "http://" + source_url if source_url.present? && source_url !~ %r{^http://}
  end
end
