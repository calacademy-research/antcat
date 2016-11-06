class PlaceObserver < ActiveRecord::Observer
  def before_update place
    # TODO probably get the references from the place.
    references = Reference.joins(publisher: [:place]).where('places.id = ?', place.id)
    references.each &:invalidate
  end
end
