# coding: UTF-8
class Place < ActiveRecord::Base
  validates_presence_of :name
  has_paper_trail
  before_update :invalidate_formatted_reference_cache

  def self.import name
    place = find_or_create_by_name name
    raise unless place.valid?
    place
  end

  def invalidate_formatted_reference_cache
    Reference.joins(publisher: [:place]).where('places.id = ?', id).each do |reference|
      reference.invalidate_formatted_reference_cache
    end
  end

end
