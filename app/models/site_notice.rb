class SiteNotice < ApplicationRecord
  include HasUserNotifications
  include Trackable

  belongs_to :user

  validates :user, presence: true
  validates :message, presence: true
  validates :title, presence: true, length: { maximum: 70 }

  scope :order_by_date, -> { order(created_at: :desc) }

  acts_as_commentable
  acts_as_readable on: :created_at
  has_paper_trail
  trackable parameters: proc { { title: title } }
end
