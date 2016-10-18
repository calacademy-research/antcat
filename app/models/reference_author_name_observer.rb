class ReferenceAuthorNameObserver < ActiveRecord::Observer
  def before_save reference_author_name
    ReferenceFormatterCache.instance.invalidate reference_author_name.reference
  end

  def before_destroy reference_author_name
    ReferenceFormatterCache.instance.invalidate reference_author_name.reference
  end
end
