class SiteNotice < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection

  include Feed::Trackable
  tracked on: :all, parameters: ->(site_notice) do
    { title: site_notice.title }
  end

  has_paper_trail
  acts_as_commentable
  acts_as_readable on: :created_at

  belongs_to :user

  validates :user, presence: true
  validates :message, presence: true, allow_blank: false
  validates :title, presence: true, allow_blank: false, length: { maximum: 70 }

  scope :order_by_date, -> { order(created_at: :desc) }
end
