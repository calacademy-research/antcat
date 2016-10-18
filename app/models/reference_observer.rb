class ReferenceObserver < ActiveRecord::Observer
  def before_update reference
    ReferenceFormatterCache.instance.invalidate reference unless reference.new_record?
  end
end
