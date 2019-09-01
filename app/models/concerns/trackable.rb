# To save additional parameters:
# `trackable parameters: proc { { name: name } }`

module Trackable
  extend ActiveSupport::Concern

  included do
    class_attribute :activity_parameters
  end

  module ClassMethods
    def trackable parameters: proc {}
      self.activity_parameters = parameters
    end
  end

  def create_activity action, edit_summary: nil, parameters: nil
    parameters ||= instance_eval(&activity_parameters)
    Activity.create_for_trackable self, action, edit_summary: edit_summary, parameters: parameters
  end
end
