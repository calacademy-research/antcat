class Feed::Activity < ActiveRecord::Base
  belongs_to :trackable, polymorphic: true
  belongs_to :user

  serialize :parameters, Hash

  # TODO probably not thread-safe
  class_attribute :enabled

  scope :order_by_date, -> { order(created_at: :desc)._include_associations }
  scope :most_recent, ->(number = 5) { order_by_date.limit(number) }
  scope :_include_associations, -> { includes(:trackable, :user) }

  class << self
    def create_activity_for_trackable trackable, action, parameters = {}
      return unless enabled?
      self.create! trackable: trackable, action: action,
        user: User.current, parameters: parameters
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
