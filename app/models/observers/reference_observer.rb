# frozen_string_literal: true

class ReferenceObserver < ActiveRecord::Observer
  def before_update reference
    References::Cache::Invalidate[reference] unless reference.new_record?
  end
end
