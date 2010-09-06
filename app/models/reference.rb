class Reference < ActiveRecord::Base

  def self.import data
    case
    when data.has_key?(:book)
      reference = BookReference.import data
    when data.has_key?(:article)
      reference = ArticleReference.import data
    end
  end

end
