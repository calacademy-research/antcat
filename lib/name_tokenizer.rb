class NameTokenizer < Tokenizer
  def get
    case
      when scan_initial:  :initial
      when scan_phrase:   :phrase
      else super
    end
  end

  def scan_phrase
    abbreviations = ['St.'].map {|abbreviation| Regexp.escape abbreviation}
    word_chars = %q{[\w\-']}
    word_expression = '(' + abbreviations.join('|') + '|' + word_chars + ')'
    @scanner.scan /#{word_expression}+(\s+#{word_expression}+)*\s*/u
  end

  def scan_initial
    # (eds.)
    return true if @scanner.scan(/\(.*?\)/u)
    
    # S. de
    return true if ['da', 'de', 'di', 'del', 'do'].any? do |preposition|
      @scanner.scan(/#{preposition}$/u) ||
      @scanner.scan(/#{preposition}\b(?=\S)/u)
    end 

    # A. or J-H. or J.-H.
    @scanner.scan(/\w\.?-\w\.\s*/u) || @scanner.scan(/\w\.\s*/u)
  end
end
