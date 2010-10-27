#  How to import an ANTBIB spreadsheet from Phil Ward:
#  1) Open the spreadsheet (e.g. ANTBIB_v1V.xls) in Excel
#  2) Select the entire contents and Format Cells to
#     turn wrapping on.
#  3) Do File | Save as Web Page..., selecting the Sheet radio button
#  4) Choose a file name with the same base as the spreadsheet, e.g.
#     ANTBIB_v1V.htm. If the file has '96' in its name, the import will
#     handle one extra column - taxonomic_notes
#  4) Run 'rake import_ward'.
#     This will delete all data and import it from the web page output.

class WardBibliography
  def initialize filename, show_progress = false
    Progress.init show_progress
    @filename = filename.to_s
    @base_filename = File.basename(@filename, File.extname(@filename))
    @new_format = @base_filename.match(/96/).present?
  end

  def import_file
    Progress.print "Importing #{@filename}"
    import_html File.read(@filename)
  end

  def import_html html
    doc = Nokogiri::HTML(html)
    rows = doc.css('tr')
    (1..(rows.length - 1)).each do |i|
      break unless save_reference rows[i].css('td')
      Progress.print '.'
    end
    Progress.puts
  end

  def save_reference columns
    return unless columns && columns[1] && !columns[1].inner_html.empty?
    col = 0;
    WardReference.create!(
      :filename        => @base_filename,
      :cite_code       => node_to_text(columns[col += 1]),
      :authors         => fix_authors(node_to_text(columns[col += 1])),
      :year            => node_to_text(columns[col += 1]),
      :date            => node_to_text(columns[col += 1]),
      :title           => node_to_text(columns[col += 1]),
      :citation        => node_to_text(columns[col += 1]),
      :taxonomic_notes => (@new_format ? node_to_text(columns[col += 1]) : nil),
      :notes           => node_to_text(columns[col += 1]),
      :possess         => node_to_text(columns[col += 1])
    )
  end

  private
  def node_to_text node
    s = node.inner_html
    s = s.gsub(/\n/, '')
    # replace italics font styling with *'s
    s = s.gsub(/<font class="font7">(.*?)<\/font>/, '*\1*')
    # remove font reset
    s = s.gsub(/<font.*?>(.*?)<\/font>/, '\1')
    # remove links
    s = s.gsub(/<a.*?>(.*?)<\/a>/, '\1')
    # translate | to *
    s = s.gsub(/\|/, '*')
    s = s.squish
    CGI.unescapeHTML(s)
  end

  def fix_authors names
    # A reference by "Radchenko, A. G.; Elmes, G. W.; Alicata, A."
    # has some weird bytes before Elmes's and Alicata's namess
    names.gsub! /\xC2\xA0/, ''

    # Transposition mistakes
    names.gsub! /MacKay, W\. P\.; Rebeles M\.; A\.; Arredondo B\.; H\. C\.; Rodríguez R\.; A\. D\.; González, D\. A\.; Vinson, S\. B\.\s*/,
      "MacKay, W. P.; Rebeles, A.; Arredondo, H.; Rodriguez, A.; Gonzalez, D.; Vinson, S. B."

    # Remove trailing periods that aren't initials or abbreviations
    unless names =~ /\(eds?\.\)/ 
      match = names.match /(\w{2,})\./
      names = names[0..-2] unless !match || ['Jr', 'Sr'].include?(match[1])
    end

    # Remove 'and collaborators'
    names.gsub!(/ and collaborators$/, '')

    # Fix typos
    names.gsub! /Medeiro, M. A. de/, 'Medeiros, M. A. de'
    names.gsub! /Gibron, J.; Sr./, 'Gibron, S. J.'
    names.gsub! /:/, ';'

    # The ' is 0x2019
    names.gsub! /O’Donnell/, "O'Donnell"

    # The s is 0x0161
    names.gsub! /Randuška/, "Randuska"

    # commas instead of semicolons
    names.gsub! /Santos-Colares, M. C., Viégas, J., Martino Roth, M. G., Loeck, A. E./, "Santos-Colares, M. C.; Viégas, J.; Martino Roth, M. G.; Loeck, A. E."

    # name without comma
    names.gsub! /Swainson W/, 'Swainson, W'

    names
  end

end
