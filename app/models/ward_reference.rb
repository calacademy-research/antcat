class WardReference < ActiveRecord::Base
  before_create :create_reference
  before_update :update_reference

  belongs_to :reference

  validates_presence_of :authors, :citation, :year, :title

  def create_reference
    self.reference = Reference.import parse
  end

  def update_reference
    reference.import parse
  end

  def self.search terms
    author_term = terms[:author]
    find_by_sql <<-SQL
      SELECT ward_references.*
        FROM ward_references
        JOIN `references` ON ward_references.reference_id = `references`.id
        JOIN sources ON `references`.source_id = sources.id
        JOIN author_participations ON sources.id = author_participations.source_id
        JOIN authors ON author_participations.author_id = authors.id
        WHERE authors.name LIKE '#{author_term}%'
      SQL
  end
  
  def parse
    parse = parse_citation
    parse[:authors] = parse_authors
    parse[:year] = parse_year
    parse[:title] = title
    parse
  end

  def parse_authors
    authors.split(/; ?/)
  end

  def parse_year
    year.to_i if year
  end

  def parse_citation
    return if citation.blank?
    parse_nested_citation || parse_book_citation || parse_journal_citation || parse_unknown_citation
  end

  def parse_nested_citation
    citation.match(/\bin: /i) or return
    {:nested => {:citation => citation}}
  end

  def parse_book_citation
    match = citation.match(/(.*?): (.*?), (.+?)$/) or return
    {:book => {
      :publisher => {:name => match[2], :place => match[1]},
      :pagination => match[3]}}
  end

  def parse_journal_citation
    parts = citation.match(/(.+?)(\S+)$/) or return
    journal_title = parts[1].strip

    parts = parts[2].match(/(.+?):(.+)$/) or return
    series_volume_issue = parse_series_volume_issue(parts[1]) or return
    pagination = parse_pagination(parts[2]) or return

    {:article => {
      :issue => {
        :journal => {:title => journal_title},
        :series => series_volume_issue[:series],
        :volume => series_volume_issue[:volume],
        :issue => series_volume_issue[:issue],
      },
      :start_page => pagination[:start_page],
      :end_page => pagination[:end_page],
      }
    }
  end

  def parse_series_volume_issue series_volume_issue
    parse = {}
    parts = series_volume_issue.match(/(\(\w+\))?(\w+)(\(\w+\))?/) or return
    parse[:series] = parts[1].match(/\((\w+)\)/)[1] if parts[1].present?
    parse[:volume] = parts[2]
    parse[:issue] = parts[3].match(/\((\w+)\)/)[1] if parts[3].present?
    parse
  end

  def parse_pagination pagination
    parse = {}
    parts = pagination.match(/(.+?)(?:-(.+?))?\.?$/) or return
    parse[:start_page] = parts[1]
    parse[:end_page] = parts[2] if parts.length == 3
    parse
  end

  def parse_unknown_citation
    {:unknown => {:citation => citation}}
  end

  def to_s
    "#{authors} #{year}. #{title}. #{citation}."
  end
end
