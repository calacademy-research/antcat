module Ward::PublisherParser

  def self.parse string
    PublisherGrammar.parse(string.strip).value rescue nil
  end

end
