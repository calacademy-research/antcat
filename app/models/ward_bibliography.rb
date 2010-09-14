#  How to import an ANTBIB spreadsheet from Phil Ward:
#  1) Open the spreadsheet in Excel
#  2) Make each column wide enough to fit its contents. The easiest way is to
#     double-click the dividing line between columns up at the top,
#     between the column letters.
#  3) Do File | Save as Web Page..., selecting the Sheet radio button
#  4) With the web page output in data/ANTBIB.htm, run 'rake import'.
#     This will delete all data and import it from the web page output.
#  Use ANTBIB96.htm for the post-1995 spreadsheet. The presence of
#  '96' in the name will enable the import to handle an extra column

class WardBibliography
  def import_file filename, show_progress = false
    Progress.init show_progress
    Progress.print "Importing #{filename}"
    html = File.read(filename)
    new_format = filename.match(/96/).present?
    import_html html, new_format, show_progress
  end

  def import_html html, new_format, show_progress = false
    @new_format = new_format
    Progress.init show_progress
    doc = Nokogiri::HTML(html)
    rows = doc.css('tr')
    (1..(rows.length - 1)).each do |i|
      break unless columns = parse_html_columns(rows[i].css('td'))
      import_reference columns
      Progress.print '.'
    end
    Progress.puts
  end

  def parse_html_columns columns
    return unless columns && columns[1] && !columns[1].inner_html.empty?
    col = 0;
    cite_code       = node_to_text(columns[col += 1])
    authors         = node_to_text(columns[col += 1])
    year_td         = columns[col += 1]
    date            = node_to_text(columns[col += 1])
    title           = remove_period_from(node_to_text(columns[col += 1]))
    citation        = remove_period_from(node_to_text(columns[col += 1]))
    taxonomic_notes = @new_format ? node_to_text(columns[col += 1]) : nil
    notes           = node_to_text(columns[col += 1])
    possess         = node_to_text(columns[col += 1])

    citation_year = remove_period_from(node_to_text(year_td))

    public_notes = editor_notes = nil
    if match = notes.match(/(?:\{(.+?)\})?(?:\s*(.*))?/)
      public_notes = match[1]
      editor_notes = match[2]
    end

    {:authors => authors,
     :citation_year => citation_year,
     :title => title,
     :citation  => citation,
     :cite_code => cite_code,
     :possess => possess,
     :date => date,
     :public_notes => public_notes,
     :editor_notes => editor_notes,
     :taxonomic_notes => taxonomic_notes}
  end

  def import_reference columns
    Reference.import parse(columns)
  end

  def parse data
    parsed_data = parse_citation data[:citation]
    parsed_data[:authors] = parse_authors data[:authors]
    parsed_data[:citation_year] = data[:citation_year]
    parsed_data[:title] = data[:title]
    parsed_data[:cite_code] = data[:cite_code]
    parsed_data[:date] = data[:date]
    parsed_data[:possess] = data[:possess]
    parsed_data[:public_notes] = data[:public_notes]
    parsed_data[:editor_notes] = data[:editor_notes]
    parsed_data[:taxonomic_notes] = data[:taxonomic_notes]
    parsed_data
  end

  def parse_authors authors
    authors.split(/; ?/)
  end

  def parse_citation citation
    return if citation.blank?
    parse_nested_citation(citation) ||
    parse_book_citation(citation) ||
    parse_article_citation(citation) ||
    parse_unknown_citation(citation)
  end

  def parse_nested_citation citation
    citation.match(/\bin: /i) or return
    {:other => citation}
  end

  def parse_book_citation citation
    match = citation.match(/(.*?): (.*?), (.+?)$/) or return
    {:book => {
      :publisher => {:name => match[2], :place => match[1]},
      :pagination => match[3]}}
  end

  def parse_article_citation citation
    parts = citation.match(/(.+?)(\S+)$/) or return
    journal_title = parts[1].strip

    parts = parts[2].match(/(.+?):(.+)$/) or return
    series_volume_issue = parts[1]
    pagination = remove_period_from parts[2]

    {:article => {:journal => journal_title, :series_volume_issue => series_volume_issue, :pagination => pagination}}
  end

  def parse_unknown_citation citation
    {:other => citation}
  end

  private
  def node_to_text node
    s = node.inner_html
    s = s.gsub(/\n/, '')
    # replace italics font styling with *'s
    s = s.gsub(/<font class="font7">(.*?)<\/font>/, '*\1*')
    # remove font reset
    s = s.gsub(/<font.*?>(.*?)<\/font>/, '\1')
    # translate | to *
    s = s.gsub(/\|/, '*')
    s = s.squish
    CGI.unescapeHTML(s)
  end

  def remove_period_from text
    text[-1..-1] == '.' ? text[0..-2] : text 
  end

end
