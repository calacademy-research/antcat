# coding: UTF-8
class ReferenceDocumentObserver < ActiveRecord::Observer

  def before_update reference_document
    ReferenceFormatterCache.instance.invalidate reference_document.reference if reference_document.reference
  end

end
