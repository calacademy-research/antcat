class Journal
  def self.search term
    search_expression = '%' + term.split('').join('%') + '%'
    journal_titles = Reference.find_by_sql "
      SELECT distinct journal_title
      FROM refs
      WHERE journal_title LIKE '#{search_expression}'
      ORDER BY journal_title
    "
    journal_titles.map {|e| e['journal_title']}
  end
end
