class ArticleReference < Reference
  belongs_to :article, :foreign_key => :source_id

  def self.import data
    create! :article => Article.import(data)
  end

end
