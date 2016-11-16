class ReferenceObserver < ActiveRecord::Observer
  def before_update reference
    reference.invalidate_caches unless reference.new_record?
  end
end
