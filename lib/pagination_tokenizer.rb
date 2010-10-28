class PaginationTokenizer < Tokenizer
  def get
    case
      when scan_roman_section_size:   :roman_section_size
      when scan_arabic_section_size:  :arabic_section_size
      when scan_section_type:         :section_type
      else super
    end
  end

  def scan_roman_section_size
    scan_section_size '[clxvi]'
  end

  def scan_arabic_section_size
    scan_section_size '\d'
  end

  def scan_section_size numeral
    @scanner.scan /#{numeral}+(-#{numeral}+)?\s*/u
  end

  def scan_section_type
    section_types = ['p', 'pp', 'pl', 'map']
    #@scanner.scan /(#{section_types.join('|')})s?\.?\b\s*/u
    @scanner.scan /(#{section_types.join('|')})s?\.?\s*/u
  end

end
