# frozen_string_literal: true

module RunInTransaction
  def execute
    ActiveRecord::Base.transaction do
      super
    end
  rescue ActiveRecord::RecordInvalid => e
    fail! e.message
  end
end
