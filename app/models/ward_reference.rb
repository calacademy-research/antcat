class WardReference < ActiveRecord::Base
  belongs_to :reference

  def self.export show_progress = false
    Progress.init show_progress
    all.each do |ward_reference|
      ward_reference.export
      Progress.print '.'
    end
    Progress.puts
  end

  def export
    reference = Reference.import to_import_format
    update_attribute(:reference, reference)
  end

  def to_import_format
    data = {}
    parse_authors data
    parse_citation data
    data[:citation_year] = remove_period_from year
    data[:cite_code] = cite_code
    data[:date] = date
    parse_notes data
    data[:possess] = possess
    data[:taxonomic_notes] = taxonomic_notes
    data[:title] = remove_period_from title
    data
  end

  def parse_authors data
    return if authors.blank?
    data[:authors] = authors.split(/; ?/)
  end

  def parse_citation data
    return if citation.blank?
    parse_nested_citation(data) ||
    parse_book_citation(data) ||
    parse_article_citation(data) ||
    parse_unknown_citation(data)
  end

  def parse_nested_citation data
    citation.match(/\bin: /i) or return
    data[:other] = citation
  end

  def parse_book_citation data
    match = citation.match(/(.*?): (.*?), (.+?)$/) or return
    data[:book] = {
      :publisher => {:name => match[2], :place => match[1]},
      :pagination => match[3]}
  end

  def parse_article_citation data
    parts = citation.match(/(.+?)(\S+)$/) or return
    journal_title = parts[1].strip

    parts = parts[2].match(/(.+?):(.+)$/) or return
    series_volume_issue = parts[1]
    pagination = remove_period_from parts[2]

    data[:article] = {:journal => journal_title, :series_volume_issue => series_volume_issue, :pagination => pagination}
  end

  def parse_unknown_citation data
    data[:other] = citation
  end

  def parse_notes data
    return if notes.blank?
    data[:public_notes] = data[:editor_notes] = ''
    if match = notes.match(/(?:\{(.+?)\})?(?:\s*(.*))?/)
      data[:public_notes] = match[1] || ''
      data[:editor_notes] = match[2] || ''
    end
  end

  def remove_period_from text
    return if text.blank?
    text[-1..-1] == '.' ? text[0..-2] : text 
  end

end
