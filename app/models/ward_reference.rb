class WardReference < ActiveRecord::Base
  before_save :parse

  validates_presence_of :authors, :citation, :year, :title

  def self.search params = {}
    scope = scoped(:order => 'authors, year')

    scope = scope.scoped :conditions => ['authors LIKE ?', "%#{params[:author]}%"] unless params[:author].blank?
    scope = scope.scoped :conditions => ['numeric_year >= ?', params[:start_year]] if params[:start_year].present?
    scope = scope.scoped :conditions => ['numeric_year <= ?', params[:end_year]] if params[:end_year].present?
    scope = scope.scoped :conditions => ['journal_title = ?', params[:journal]] unless params[:journal].blank?

    scope
  end
  
  def parse
    self.numeric_year = year.to_i if year
    parse_citation
  end

  def parse_citation
    return if citation.blank?
    parse_nested_citation || parse_book_citation || parse_journal_citation || parse_unknown_citation
  end

  def parse_nested_citation
    citation.match(/\bin: /i) or return
    self.kind = 'nested'
    true
  end

  def parse_book_citation
    match = citation.match(/(.*?): (.*?), (.+?)$/) or return false
    self.kind = 'book'
    self.place = match[1]
    self.publisher = match[2]
    self.pagination = match[3]
    true
  end

  def parse_journal_citation
    parts = citation.match(/(.+?)(\S+)$/) or return false
    self.journal_title = parts[1].strip

    parts = parts[2].match(/(.+?):(.+)$/) or return false
    parse_series_volume_issue(parts[1]) or return false
    parse_pagination(parts[2]) or return false

    self.kind = 'journal'
    true
  end

  def parse_series_volume_issue series_volume_issue
    parts = series_volume_issue.match(/(\(\w+\))?(\w+)(\(\w+\))?/) or return false
    self.series = parts[1].match(/\((\w+)\)/)[1] if parts[1].present?
    self.volume = parts[2]
    self.issue = parts[3].match(/\((\w+)\)/)[1] if parts[3].present?
    true
  end

  def parse_pagination pagination
    parts = pagination.match(/(.+?)(?:-(.+?))?\.?$/) or return false
    self.start_page = parts[1]
    self.end_page = parts[2] if parts.length == 3
    true
  end

  def parse_unknown_citation
    self.kind = 'unknown'
    true
  end

  def to_s
    "#{authors} #{year}. #{title}. #{citation}."
  end
end
