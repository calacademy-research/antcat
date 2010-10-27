require 'strscan'

class Tokenizer
  class UnexpectedInputError < StandardError; end
  class ExpectationError < StandardError; end

  def initialize string
    @scanner = StringScanner.new string
  end

  def get
    case
      when @scanner.scan(/,\s*/u):      :comma 
      when @scanner.scan(/\.\s*/u):     :period 
      when @scanner.scan(/;\s*/u):      :semicolon
      when @scanner.scan(/\s*$/u):      :eos
      else raise UnexpectedInputError, "Scanning \"#{@scanner.string}\", at \"#{@scanner.rest}\""
    end
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
