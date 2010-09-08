class Article < Source

  def self.import data
    issue = Issue.import(data[:article][:issue])
    Article.find_or_create_by_issue_id_and_year_and_title_and_start_page_and_end_page(
      :authors => Author.import(data[:authors]),
      :year => data[:year],
      :title => data[:title],
      :start_page => data[:article][:start_page],
      :end_page => data[:article][:end_page],
      :issue => issue
    )
  end
end
