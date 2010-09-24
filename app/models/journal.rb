class Journal < ActiveRecord::Base
  def self.import title
    find_or_create_by_title(title)
  end

  def self.search term
    search_expression = term.split('').join('%') + '%'
    all(:select => 'title', :conditions => ["title LIKE ?", search_expression], :order => :title).map(&:title)
  end

end
