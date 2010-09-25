class Publisher < ActiveRecord::Base
  has_many :books

  def self.import data
    find_or_create_by_name_and_place(data[:name], data[:place])
  end

  def self.import_string string
    match = string.match(/(?:(.*?): ?)?(.*)/)
    import :name => match[2], :place => match[1] unless match[2].blank?
  end

  def to_s
    string = place.present? ? "#{place}: " : ''
    string << name
  end

  def self.search term
    search_expression = '%' + term.split('').join('%') + '%'
    all(:conditions => ["CONCAT(COALESCE(place, ''), ':', name) LIKE ?", search_expression]).map(&:to_s)
  end

end
