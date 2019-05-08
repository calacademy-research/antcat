# Usage:
# In the model, include `Trackable` and call:
# `trackable on: [:create, :destroy, :destroy]` for those hooks
# `trackable` no hooks
#
# To save additional parameters:
# `trackable parameters: proc { { name: name } }`

module Trackable
  extend ActiveSupport::Concern

  included do
    class_attribute :activity_parameters
  end

  module ClassMethods
    def trackable on: [], parameters: proc {}
      self.activity_parameters = parameters
      on.each { |action| include "TrackableActions::#{action.capitalize}".constantize }
    end
  end

  def create_activity action, edit_summary: nil, parameters: nil
    parameters ||= instance_eval &activity_parameters
    Activity.create_for_trackable self, action, edit_summary: edit_summary, parameters: parameters
  end
end
