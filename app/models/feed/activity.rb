# To be added:
# Support for `parameters`
#
# Upcoming class methods:
#   create_activity (without a trackable)
#   enabled?
#   enabled=
#   without_tracking
#   with_tracking

class Feed::Activity < ActiveRecord::Base
  belongs_to :trackable, polymorphic: true
  belongs_to :user

  class << self
    def create_activity_for_trackable trackable, action
      self.create! trackable: trackable, action: action,
        user: User.current_user
    end
  end
end
