require 'strscan'

module AuthorParser

  def self.get_author_names string
    @names = []
    return @names unless string.present?
    @tokenizer = NameTokenizer.new string
    get_names
    string.replace @tokenizer.rest
    @names
  end

  def self.get_names
    loop do
      @names << get_name
      break unless @tokenizer.skip_over :semicolon
    end
    @tokenizer.skip_over :period
  end

  def self.get_name
    @tokenizer.start_capturing
    @tokenizer.expect :phrase
    if @tokenizer.skip_over :comma
      while @tokenizer.skip_over :initial; end
    end
    @tokenizer.captured
  end

  def self.get_name_parts string
    parts = {}
    return parts unless string.present?
    matches = string.match /(.*?), (.*)/u
    unless matches
      parts[:last] = string
    else
      parts[:last] = matches[1]
      parts[:first_and_initials] = matches[2]
    end
    parts
  end

end
