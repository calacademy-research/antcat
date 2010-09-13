class Reference < ActiveRecord::Base
  has_many :author_participations
  has_many :authors, :through => :author_participations
  belongs_to :journal

  validates_presence_of :title

  def self.import data
    create_data = {
      :authors => Author.import(data[:authors]),
      :citation_year => data[:citation_year],
      :year => data[:year],
      :title => data[:title],
      :cite_code => data[:cite_code],
      :possess => data[:possess],
      :date => data[:date],
      :public_notes => data[:public_notes],
      :taxonomic_notes => data[:taxonomic_notes],
      :editor_notes => data[:editor_notes],
    }
    case
    when data[:book]
      BookReference.import create_data, data[:book]
    when data[:article]
      ArticleReference.import create_data, data[:article]
    end
  end

  def self.search terms = {}
    conditions = []
    conditions_arguments = {}
    joins = [:authors]

    if terms[:author].present?
      conditions << 'authors.name LIKE :author'
      conditions_arguments[:author] = "#{terms[:author]}%"
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

    all :select => "`references`.*, GROUP_CONCAT(authors.name SEPARATOR '; ') AS authors_string",
        :joins => joins,
        :conditions => [conditions.join(' AND '), conditions_arguments],
        :order => 'authors_string, citation_year',
        :group => 'references.id'
  end

  def citation
  end

  def authors_string
    authors.map(&:name).join('; ')
  end

  def add_period_if_necessary string
    string << '.' unless string[-1..-1] == '.'
    string
  end

end
