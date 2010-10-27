require 'strscan'

class NameTokenizer
  class UnexpectedInputError < StandardError; end
  class ExpectationError < StandardError; end

  def initialize string
    @scanner = StringScanner.new string
  end

  def get
    token = case
      when scan_initial:                :initial
      when scan_phrase:                 :phrase
      when @scanner.scan(/,\s*/u):      :comma 
      when @scanner.scan(/\.\s*/u):     :period 
      when @scanner.scan(/;\s*/u):      :semicolon
      when @scanner.scan(/\s*$/u):      :eos
      else raise UnexpectedInputError, "Scanning \"#{@scanner.string}\", at \"#{@scanner.rest}\""
    end
    token
  end

  def scan_phrase
    abbreviations = ['St.'].map {|abbreviation| Regexp.escape abbreviation}
    word_chars = %q{[\w\-']}
    word_expression = '(' + abbreviations.join('|') + '|' + word_chars + ')'
    @scanner.scan /#{word_expression}+(\s+#{word_expression}+)*\s*/
  end

  def scan_initial
    # (eds.)
    return true if @scanner.scan(/\(.*?\)/)
    
    # S. de
    return true if ['da', 'de', 'di', 'del', 'do'].any? do |preposition|
      @scanner.scan(/#{preposition}$/u) ||
      @scanner.scan(/#{preposition}\b(?=\S)/u)
    end 

    # A. or J-H. or J.-H.
    @scanner.scan(/\w\.?-\w\.\s*/u) || @scanner.scan(/\w\.\s*/u)
  end

  def expect tokens
    unless [tokens].flatten.include? get
      raise ExpectationError, "Scanning \"#{@scanner.string}\", at \"#{@scanner.rest}, expecting :#{tokens}"
    end
  end

  def rest
    @scanner.rest
  end

  def eos?
    @scanner.eos?
  end

  def captured
    @start_of_capture ||= 0
    return '' unless @scanner.pos > 0
    @scanner.string[@start_of_capture..(@scanner.pos - 1)].strip
  end

  def skip_over tokens_to_skip
    token = get
    return true if [tokens_to_skip].flatten.include? token
    @scanner.unscan unless token == :eos
    false
  end

  def start_capturing
    @start_of_capture = @scanner.pos
  end
end
