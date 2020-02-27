class ReferenceDocumentObserver < ActiveRecord::Observer
  def before_update reference_document
    to_invalidate = reference_document&.reference
    References::Cache::Invalidate[to_invalidate] if to_invalidate
  end
end
