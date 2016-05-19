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

    def create_activity action, parameters = {}
      self.create_activity_for_trackable nil, action, parameters
    end

    def enabled?
      self.enabled != false
    end

    def without_tracking &block
      self._with_or_without_tracking false, &block
    end

    def with_tracking &block
      self._with_or_without_tracking true, &block
    end

    def _with_or_without_tracking value
      before = enabled
      self.enabled = value
      yield
    ensure
      self.enabled = before
    end
  end
end
