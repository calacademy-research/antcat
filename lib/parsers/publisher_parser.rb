# coding: UTF-8
module PublisherParser

  def self.parse string
    PublisherGrammar.parse(string.strip).value rescue nil
  end

end
