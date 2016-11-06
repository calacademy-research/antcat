class ReferenceObserver < ActiveRecord::Observer
  def before_update reference
    reference.invalidate_cache unless reference.new_record?
  end
end
