# Upcoming class methods:
#   create_activity (without a trackable)
#   enabled?
#   enabled=
#   without_tracking
#   with_tracking

class Feed::Activity < ActiveRecord::Base
  belongs_to :trackable, polymorphic: true
  belongs_to :user

  serialize :parameters, Hash

  class << self
    def create_activity_for_trackable trackable, action, parameters = {}
      self.create! trackable: trackable, action: action,
        user: User.current_user, parameters: parameters
    end
  end
end
