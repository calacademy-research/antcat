# Upcoming class methods:
#   create_activity (without a trackable)
#   without_tracking
#   with_tracking

class Feed::Activity < ActiveRecord::Base
  belongs_to :trackable, polymorphic: true
  belongs_to :user

  serialize :parameters, Hash

  class_attribute :enabled

  class << self
    def create_activity_for_trackable trackable, action, parameters = {}
      return unless enabled?
      self.create! trackable: trackable, action: action,
        user: User.current_user, parameters: parameters
    end

    def enabled?
      self.enabled != false
    end
  end
end
