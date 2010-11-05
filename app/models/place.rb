class Place < ActiveRecord::Base

  validates_presence_of :name

  def self.import name
    find_or_create_by_name name
  end

  #def self.search term
    #search_expression = '%' + term.split('').join('%') + '%'
    #all(:conditions => ["CONCAT(COALESCE(place, ''), ':', name) LIKE ?", search_expression]).map(&:to_s)
  #end

end
