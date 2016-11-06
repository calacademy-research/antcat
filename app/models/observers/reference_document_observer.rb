class ReferenceDocumentObserver < ActiveRecord::Observer
  def before_update reference_document
    reference_document.try(:reference).try(:invalidate)
  end
end
