class Journal
  def self.search term
    search_expression = '%' + term.split('').join('%') + '%'
    journal_titles = WardReference.all(
      :select => 'distinct journal_title',
      :conditions => "journal_title LIKE '#{search_expression}'",
      :order => :journal_title).map(&:journal_title)
  end
end
