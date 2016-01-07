class PlaceObserver < ActiveRecord::Observer

  def before_update place
    Reference.joins(publisher: [:place]).where('places.id = ?', place.id).each do |reference|
      ReferenceFormatterCache.instance.invalidate reference
    end
  end

end
