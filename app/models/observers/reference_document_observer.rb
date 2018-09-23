class ReferenceDocumentObserver < ActiveRecord::Observer
  def before_update reference_document
    reference_document&.reference&.invalidate_caches
  end
end
