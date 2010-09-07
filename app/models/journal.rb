class Journal < ActiveRecord::Base
  has_many :issues

  def self.import data
    find_or_create_by_title(data[:title])
  end

  def self.search term
    search_expression = '%' + term.split('').join('%') + '%'
    all(:select => 'title', :conditions => ["title LIKE ?", search_expression], :order => :title).map(&:title)
  end
end
