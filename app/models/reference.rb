class Reference < ActiveRecord::Base
  set_table_name 'refs'

    before_save :parse

  def self.search params = {}
    scope = scoped(:order => 'authors, year')

    scope = scope.scoped :conditions => ['authors LIKE ?', "%#{params[:author]}%"] unless params[:author].blank?
    scope = scope.scoped :conditions => ['numeric_year >= ?', params[:start_year]] if params[:start_year].present?
    scope = scope.scoped :conditions => ['numeric_year <= ?', params[:end_year]] if params[:end_year].present?
    scope = scope.scoped :conditions => ['journal_title = ?', params[:journal]] unless params[:journal].blank?

    scope
  end
  
#  How to import an ANTBIB spreadsheet from Phil Ward:
#  1) Open the spreadsheet in Excel
#  2) Make each column wide enough to fit its contents. The easiest way is to double-click the dividing line between columns up at the top,
#     between the column letters.
#  3) Do File | Save as Web Page..., selecting the Sheet radio button
#  4) With the web page output in data/ANTBIB.htm, run 'rake import'.
#     This will delete all references and import them from the web page output.
#  Use ANTBIB96.htm for the post-1995 spreadsheet. The presence of
#  '96' in the name will enable the import to handle an extra column

  def self.import(filename, show_progress = false)
    html = File.read(filename)
    new_format = filename.match /96/
    doc = Nokogiri::HTML(html)
    trs = doc.css('tr')
    $stderr.print "Importing #{filename}" if show_progress
    (1..(trs.length - 1)).each do |i|
      $stderr.print '.' if show_progress
      tds = trs[i].css('td')
      break unless tds && tds[1] && !tds[1].inner_html.empty?

      col = 0;
      cite_code       = node_to_text(tds[col += 1])
      authors         = node_to_text(tds[col += 1])
      year_td         = tds[col += 1]
      date            = node_to_text(tds[col += 1])
      title           = remove_period_from(node_to_text(tds[col += 1]))
      citation        = node_to_text(tds[col += 1])
      taxonomic_notes = new_format ? node_to_text(tds[col += 1]) : nil
      notes           = node_to_text(tds[col += 1])
      possess         = node_to_text(tds[col += 1])

      year = remove_period_from(node_to_text(year_td))

      reference = Reference.new(:cite_code => cite_code, :authors => authors, :year => year, :date => date, :title => title,
                                :citation  => citation, :possess => possess, :taxonomic_notes => taxonomic_notes)
      reference.parse_citation
      reference.parse_notes notes
      reference.save!
    end
    $stderr.puts if show_progress
  end

  def parse_citation
    return if citation.blank?
    parse_nested_citation || parse_book_citation || parse_journal_citation || parse_unknown_citation
  end

  def parse_notes notes
    match = notes.match(/(?:\{(.+?)\})?(?:\s*(.*))?/) or return
    self.public_notes = match[1]
    self.editor_notes = match[2]
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

  def self.node_to_text node
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

  def self.node_to_integer node
    node.inner_html.to_i
  end

  def self.remove_period_from text
    text[-1..-1] == '.' ? text[0..-2] : text 
  end

  def parse
    self.numeric_year = year.to_i if year
    parse_citation
  end
end
