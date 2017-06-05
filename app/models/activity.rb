class Activity < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection
  include FilterableWhere

  self.per_page = 30

  belongs_to :trackable, polymorphic: true
  belongs_to :user

  scope :ids_desc, -> { order(id: :desc) }
  scope :most_recent, ->(number = 5) { ids_desc.limit(number).include_associations }
  scope :include_associations, -> { includes(:trackable, :user) }

  serialize :parameters, Hash

  def self.create_for_trackable trackable, action, parameters = {}
    return unless Feed.enabled?

    create! trackable: trackable, action: action,
      user: User.current, parameters: parameters
  end

  def self.create_without_trackable action, parameters = {}
    create_for_trackable nil, action, parameters
  end

  def pagination_page
    index = Activity.ids_desc.pluck(:id).index(id)
    per_page = self.class.per_page
    (index + per_page) / per_page
  end
end
