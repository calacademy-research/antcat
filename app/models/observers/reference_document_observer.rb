class ReferenceDocumentObserver < ActiveRecord::Observer
  def before_update reference_document
    if reference_document.reference
      ReferenceFormatterCache.instance.invalidate reference_document.reference
    end
  end
end
