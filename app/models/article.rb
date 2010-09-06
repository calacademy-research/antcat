class Article < Source
  belongs_to :issue

  def self.import data
    Article.create!(
      :authors => Author.import(data[:authors]),
      :year => data[:year],
      :title => data[:title],
      :start_page => data[:article][:start_page],
      :end_page => data[:article][:end_page],
      :issue => Issue.import(data[:article][:issue]))
  end
end
