# TODO something. Probably split.

class Feed::Activity < ActiveRecord::Base
  self.per_page = 30

  class_attribute :enabled # TODO probably not thread-safe

  belongs_to :trackable, polymorphic: true
  belongs_to :user

  scope :ids_desc, -> { order(id: :desc) }
  scope :most_recent, ->(number = 5) { ids_desc.limit(number).include_associations }
  scope :include_associations, -> { includes(:trackable, :user) }

  serialize :parameters, Hash

  class << self
    def create_activity_for_trackable trackable, action, parameters = {}
      return unless enabled?
      create! trackable: trackable, action: action,
        user: User.current, parameters: parameters
    end

    def create_activity action, parameters = {}
      create_activity_for_trackable nil, action, parameters
    end

    def enabled?
      enabled != false
    end

    def without_tracking &block
      _with_or_without_tracking false, &block
    end

    def with_tracking &block
      _with_or_without_tracking true, &block
    end

    def _with_or_without_tracking value
      before = enabled
      self.enabled = value
      yield
    ensure
      self.enabled = before
    end
  end

  def pagination_page
    index = Feed::Activity.ids_desc.pluck(:id).index(id)
    per_page = self.class.per_page
    (index + per_page) / per_page
  end
end
