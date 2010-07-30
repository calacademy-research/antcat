class Journal
  def self.search term
    search_expression = '%' + term.split('').join('%') + '%'
    journal_titles = Reference.find_by_sql "
      SELECT distinct short_journal_title
      FROM refs
      WHERE short_journal_title LIKE '#{search_expression}'
      ORDER BY short_journal_title
    "
    journal_titles.map {|e| e['short_journal_title']}
  end
end
