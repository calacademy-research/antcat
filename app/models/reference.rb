class Reference < ActiveRecord::Base
  has_many :author_participations
  has_many :authors, :through => :author_participations

  def self.import data
    create_data = {
      :citation_year => data[:citation_year],
      :cite_code => data[:cite_code],
      :date => data[:date],
      :editor_notes => data[:editor_notes],
      :possess => data[:possess],
      :public_notes => data[:public_notes],
      :taxonomic_notes => data[:taxonomic_notes],
      :title => data[:title],
      :year => data[:year],
      :authors => Author.import(data[:authors]),

    }
    case
    when data.has_key?(:book)
      reference = BookReference.import create_data[:book], data
    when data.has_key?(:article)
      reference = ArticleReference.import create_data[:article], data
    end
  end

  def self.search terms = {}
    conditions = []
    conditions_arguments = {}
    source_joins = []

    if terms[:author].present?
      conditions << 'authors.name LIKE :author'
      conditions_arguments[:author] = "#{terms[:author]}%"
      source_joins << :authors
    end

    if terms[:journal].present?
      conditions << 'journals.title LIKE :journal'
      conditions_arguments[:journal] = terms[:journal]
      source_joins << {:issue => :journal}
    end

    if terms[:start_year].present?
      conditions << 'year >= :start_year'
      conditions_arguments[:start_year] = terms[:start_year]
    end

    if terms[:end_year].present?
      conditions << 'year <= :end_year'
      conditions_arguments[:end_year] = terms[:end_year]
    end

    all :joins => {:reference => {:source => source_joins}},
        :conditions => [conditions.join(' AND '), conditions_arguments],
        :order => 'authors, year'
  end

end
