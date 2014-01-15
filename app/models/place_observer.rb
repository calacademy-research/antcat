class PlaceObserver < ActiveRecord::Observer

  def before_update place
    Reference.joins(publisher: [:place]).where('places.id = ?', place.id).each do |reference|
      reference.invalidate_formatted_reference_cache
    end
  end

end
