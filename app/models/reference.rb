class Reference < ActiveRecord::Base
  set_table_name 'refs'
  attr_accessible :authors, :year, :title, :citation, :notes, :possess, :date, :excel_file_name, :created_at, :updated_at, :cite_code

  def self.search params
    scope = scoped({})
    scope = scope.scoped :conditions => ['authors LIKE ?', "%#{params[:author]}%"] unless params[:author].blank?
    scope
  end
  
#  How to import an ANTBIB spreadsheet from Phil Ward:
#  1) Open the spreadsheet in Excel
#  2) Make each column wide enough to fit its contents. The easiest way is to double-click the dividing line between columns up at the top,
#     between the column letters.
#  3) Do File | Save as Web Page..., selecting the Sheet radio button
#  4) With the web page output in data/ANTBIB.htm, run 'rake import'.
#     This will delete all references and import them from the web page output.

  def self.import(filename)
    html = File.read(filename)
    doc = Nokogiri::HTML(html)
    trs = doc.css('tr')
    (1..(trs.length - 1)).each do |i|
      tds = trs[i].css('td')
      if tds && !tds[0].inner_html.empty?
        Reference.create!(
                :cite_code        => node_to_text(tds[0]),
                :authors          => node_to_text(tds[1]),
                :year             => node_to_text(tds[2]),
                :date             => node_to_text(tds[3]),
                :title            => node_to_text(tds[4]),
                :citation         => node_to_text(tds[5]),
                :notes            => node_to_text(tds[6]),
                :possess          => node_to_text(tds[7]),
                :excel_file_name  => filename)
      end
    end
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


end
