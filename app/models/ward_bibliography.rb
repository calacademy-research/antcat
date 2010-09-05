class WardBibliography
#  How to import an ANTBIB spreadsheet from Phil Ward:
#  1) Open the spreadsheet in Excel
#  2) Make each column wide enough to fit its contents. The easiest way is to double-click the dividing line between columns up at the top,
#     between the column letters.
#  3) Do File | Save as Web Page..., selecting the Sheet radio button
#  4) With the web page output in data/ANTBIB.htm, run 'rake import'.
#     This will delete all references and import them from the web page output.
#  Use ANTBIB96.htm for the post-1995 spreadsheet. The presence of
#  '96' in the name will enable the import to handle an extra column

  def import_file filename, show_progress = false
    Progress.init show_progress
    Progress.print "Importing #{filename}"
    html = File.read(filename)
    new_format = filename.match(/96/).present?
    import html, new_format, show_progress
  end

  def import html, new_format, show_progress = false
    Progress.init show_progress
    doc = Nokogiri::HTML(html)
    trs = doc.css('tr')
    (1..(trs.length - 1)).each do |i|
      Progress.print '.'
      tds = trs[i].css('td')
      break unless tds && tds[1] && !tds[1].inner_html.empty?

      col = 0;
      cite_code       = node_to_text(tds[col += 1])
      authors         = node_to_text(tds[col += 1])
      year_td         = tds[col += 1]
      date            = node_to_text(tds[col += 1])
      title           = remove_period_from(node_to_text(tds[col += 1]))
      citation        = remove_period_from(node_to_text(tds[col += 1]))
      taxonomic_notes = new_format ? node_to_text(tds[col += 1]) : nil
      notes           = node_to_text(tds[col += 1])
      possess         = node_to_text(tds[col += 1])

      year = remove_period_from(node_to_text(year_td))

      authors = '[Authors missing from import]' if authors.blank?
      citation = '[Citation missing from import]' if citation.blank?
      title = '[Title missing from import]' if title.blank?
      year = '[Year missing from import]' if year.blank?

      public_notes = editor_notes = nil
      if match = notes.match(/(?:\{(.+?)\})?(?:\s*(.*))?/)
        public_notes = match[1]
        editor_notes = match[2]
      end

      reference = WardReference.create!(:cite_code => cite_code, :authors => authors, :year => year,
                                        :date => date, :title => title, :citation  => citation,
                                        :possess => possess, :public_notes => public_notes,
                                        :editor_notes => editor_notes,
                                        :taxonomic_notes => taxonomic_notes)
    end
    Progress.puts
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
