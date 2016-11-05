class Comment < ActiveRecord::Base
  include Feed::Trackable

  belongs_to :commentable, polymorphic: true
  belongs_to :user

  scope :order_by_date, -> { order(created_at: :desc)._include_associations }
  scope :most_recent, ->(number = 5) { order_by_date.limit(number) }
  scope :_include_associations, -> { includes(:commentable, :user) }

  validates :user, presence: true
  validates :body, presence: true

  acts_as_nested_set scope: [:commentable_id, :commentable_type]
  tracked on: :create

  def self.build_comment commentable, user, body = ""
    new commentable: commentable, body: body, user: user
  end
end
