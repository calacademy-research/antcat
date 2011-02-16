class Place < ActiveRecord::Base

  validates_presence_of :name

  def self.import name
    place = find_or_create_by_name name
    raise unless place.valid?
    place
  end

end
