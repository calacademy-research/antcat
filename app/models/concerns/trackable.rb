# frozen_string_literal: true

# Usage:
# ```
#   # in app/models/model.rb
#   include Trackable
#
#   trackable parameters: proc { { name: name } } # Capture parameters, optional.
# ```

module Trackable
  extend ActiveSupport::Concern

  included do
    class_attribute :activity_parameters
  end

  # rubocop:disable Lint/EmptyBlock
  class_methods do
    def trackable parameters: proc {}
      self.activity_parameters = parameters
    end
  end
  # rubocop:enable Lint/EmptyBlock

  def create_activity action, user, edit_summary: nil, parameters: nil
    parameters ||= instance_eval(&activity_parameters)
    Activity.create_for_trackable self, action, user: user, edit_summary: edit_summary, parameters: parameters
  end
end
