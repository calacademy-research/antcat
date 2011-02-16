class Publisher < ActiveRecord::Base
  belongs_to :place
  has_many :books

  validates_presence_of :name

  def self.import data
    return unless data[:name].present?
    place = Place.import data[:place]
    publisher = find_or_create_by_name_and_place_id(data[:name], place.id)
    raise unless publisher.valid?
    publisher
  end

  def self.import_string string
    parts = PublisherParser.parse string
    import parts[:publisher] if parts
  end

  def to_s
    string = place.present? ? "#{place.name}: " : ''
    string << name
  end

  def self.search term
    search_expression = '%' + term.split('').join('%') + '%'
    all(:joins => 'LEFT OUTER JOIN places ON place_id = places.id',
        :conditions => ["CONCAT(COALESCE(places.name, ''), ':', publishers.name) LIKE ?", search_expression]).map(&:to_s)
  end

end
