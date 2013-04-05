# coding: UTF-8
class Place < ActiveRecord::Base

  validates_presence_of :name

  has_paper_trail

  def self.import name
    place = find_or_create_by_name name
    raise unless place.valid?
    place
  end

end
