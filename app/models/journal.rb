class Journal < ActiveRecord::Base
  has_many :references
  def self.search term
    search_expression = '%' + term.split('').join('%') + '%'
    journal_titles = find_by_sql "
      SELECT title
      FROM journals
      WHERE title LIKE '#{search_expression}'
      ORDER BY title
    "
    journal_titles.map { |e| e['title'] }
  end

#  How to import a serials spreadsheet from Phil Ward:
#  1) Open the spreadsheet in Excel
#  2) Make each column wide enough to fit its contents. The easiest way is to double-click the dividing line between columns up at the top,
#     between the column letters.
#  3) Do File | Save as Web Page..., selecting the Sheet radio button
#  4) With the web page output in data/ANTBIB.htm, run 'rake import:serials'.
#     This will delete all journals and import them from the web page output.
#  5) Doing this import will invalidate all Reference records that point to them, so do
#     a reference import right afterwards.

  def self.import(filename, show_progress = false)
    html = File.read(filename)
    doc = Nokogiri::HTML(html)
    trs = doc.css('tr')
    $stderr.print "Importing #{filename}" if show_progress
    (1..(trs.length - 1)).each do |i|
      $stderr.print '.' if show_progress
      tds = trs[i].css('td')
      if tds && !tds[0].inner_html.empty?
        journal = Journal.create!({
          :title        => node_to_text(tds[1]),
          :short_title  => node_to_text(tds[2]),
        })
      end
    end
    $stderr.puts if show_progress
  end

  def self.node_to_text node
    s = node.inner_html
    s = s.gsub(/\n/, '')
    s = s.squish
    CGI.unescapeHTML(s)
  end

end
