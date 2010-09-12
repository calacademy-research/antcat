class ArticleReference < Reference
  belongs_to :journal

  def self.import create_data, data
    ArticleReference.create! create_data.merge(
      :issue => data[:issue],
      :pagination => data[:pagination],
      :journal => Journal.import(data[:journal])
    )
  end

end
