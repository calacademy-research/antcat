# coding: UTF-8
class ReferenceDocumentObserver < ActiveRecord::Observer

  def before_update
    reference.formatted_cache = nil if reference
  end

end
