# frozen_string_literal: true

# Runs an operation in a database transaction: on a validation error everything is rolled back and the operation
# fails with the message.
module RunInTransaction
  def execute
    ActiveRecord::Base.transaction do
      super
    end
  rescue ActiveRecord::RecordInvalid => e
    fail! e.message
  end
end
