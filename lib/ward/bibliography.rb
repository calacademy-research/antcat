#  How to import an ANTBIB spreadsheet from Phil Ward:
#  1) Open the spreadsheet (e.g. ANTBIB_v1V.xls) in Excel
#  2) Select the entire contents and Format Cells to
#     turn wrapping on.
#  3) Do File | Save as Web Page..., selecting the Sheet radio button
#  4) Save the file as ANTBIB.htm or ANTBIB96.htm. If the file has
#     '96' in its name, the import will handle one extra column -
#     taxonomic_notes.
#  4) Run 'rake import_ward'.
#     This will delete all data and import it from the web page output.

class Ward::Bibliography
  def initialize filename, show_progress = false
    Progress.init show_progress
    @filename = filename.to_s
    @base_filename = File.basename(@filename, File.extname(@filename))
    @new_format = @base_filename =~ /96/
  end

  def import_file
    Progress.print "Importing #{@filename}"
    import_html File.read(@filename)
  end

  def import_html html
    doc = Nokogiri::HTML(html)
    rows = doc.css('tr')
    (1..(rows.length - 1)).each do |i|
      break unless import_reference rows[i].css('td')
      Progress.dot
    end
    Progress.puts
  end

  def import_reference columns
    return unless columns && columns[1] && !columns[1].inner_html.empty?
    col = 0;
    data = {
      :filename        => @base_filename,
      :cite_code       => node_to_text(columns[col += 1]),
      :authors         => fix_authors(node_to_text(columns[col += 1])),
      :year            => node_to_text(columns[col += 1]),
      :date            => node_to_text(columns[col += 1]),
      :title           => node_to_text(columns[col += 1]),
      :citation        => fix(node_to_text(columns[col += 1])),
      :notes           => node_to_text(columns[col += 1]),
      :editor_notes    => (@new_format ? node_to_text(columns[col += 1]) : nil),
      :taxonomic_notes => (@new_format ? node_to_text(columns[col += 1]) : nil),
      :possess         => node_to_text(columns[col += 1])
    }

    fix_data data

    WardReference.create!(data) unless data[:cite_code] == '8357'
  end

  private
  def node_to_text node
    s = node.inner_html

    s.gsub! /\n/, ''
    s.gsub! /&nbsp;/, ' '

    # replace default font style with *'s when the next font tag is for font0
    s.gsub! /^([^<]+)(?=<font class="font0">)/, '*\1*'
    
    # replace italics font styling with *'s
    s.gsub! /<font class="font[^0]+">(.*?)<\/font>/, '*\1*'
    # remove font reset
    s.gsub! /<font.*?>(.*?)<\/font>/, '\1'
    # remove links
    s.gsub! /<a.*?>(.*?)<\/a>/, '\1'
    # get rid of remaining <span>s
    s.gsub! %r{<span.*?/span>}, ' '
    # translate | to *
    s.gsub! /\|/, '*'

    s.squish!
    CGI.unescapeHTML s
  end

  def fix_authors string
    string = fix string
    
    # Transposition mistakes
    string.gsub! /MacKay, W\. P\.; Rebeles M\.; A\.; Arredondo B\.; H\. C\.; Rodríguez R\.; A\. D\.; González, D\. A\.; Vinson, S\. B\.\s*/,
      "MacKay, W. P.; Rebeles, A.; Arredondo, H.; Rodriguez, A.; Gonzalez, D.; Vinson, S. B."

    # Remove trailing periods that aren't initials or abbreviations
    unless string =~ /\(eds?\.\)/ 
      match = string.match /(\w{2,})\./
      string = string[0..-2] unless !match || ['Jr', 'Sr'].include?(match[1])
    end

    string.gsub! /:/, ';'

    string
  end

  def fix string
    string.gsub! /\(_\.\)/, 'Unknown'

    # A reference by "Radchenko, A. G.; Elmes, G. W.; Alicata, A."
    # has some weird bytes before Elmes's and Alicata's namess
    string.gsub! /\xC2\xA0/, ''

    # weird space characters
    string.gsub! /\x00\xA0/, ' '

    # Remove 'and collaborators'
    string.gsub!(/ and collaborators$/, '')

    # Fix typos
    string.gsub! /Medeiro, M. A. de/, 'Medeiros, M. A. de'
    string.gsub! /Gibron, J.; Sr./, 'Gibron, S. J.'

    # The ' is 0x2019
    string.gsub! /O’Donnell/, "O'Donnell"

    # The s is 0x0161
    string.gsub! /Randuška/, "Randuska"

    # commas instead of semicolons
    string.gsub! /Santos-Colares, M. C., Viégas, J., Martino Roth, M. G., Loeck, A. E./, "Santos-Colares, M. C.; Viégas, J.; Martino Roth, M. G.; Loeck, A. E."

    # name without comma
    string.gsub! /Swainson W/, 'Swainson, W'

    # semicolon before generation number
    string.gsub! /Coody, C. J.; Watkins, J. F.; II/, "Coody, C. J.; Watkins, J. F., II"

    # semicolon instead of comma
    string.gsub! /van Harten; A/, 'van Harten, A.'

    # missing period
    string.gsub! /van Harten, A$/, 'van Harten, A.'

    # missing comma
    string.gsub! /Cerdá X./, 'Cerdá, X.'

    string
  end

  def fix_data data
    # a very special case indeed
    if data[:citation] =~ /Extrait des .+ Lisbonne: Imprimerie de la Librairie/
      data[:title] << '. Extrait des Mémoires publiés par la Société Portugaise des Sciences Naturelles'
      data[:citation] = 'Lisbonne: Imprimerie de la Librairie Ferin, 4 pp.'
    elsif data[:citation] =~ /Achtes Programm des Gymnasiums in Bozen. Bozen: Ebersche Buchdruckerei, 34 pp./
      data[:title] << '. Achtes Programm des Gymnasiums in Bozen'
      data[:citation] = 'Bozen: Ebersche Buchdruckerei, 34 pp.'
    elsif data[:citation] =~ /103 :20-29/
      data[:citation].gsub! /103 :20-29/, '103:20-29'
    end
  end

end
