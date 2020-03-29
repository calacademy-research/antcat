# frozen_string_literal: true

class Comment < ApplicationRecord
  include Trackable

  BODY_MAX_LENGTH = 100_000

  belongs_to :commentable, polymorphic: true
  belongs_to :user

  validates :body, presence: true, length: { maximum: BODY_MAX_LENGTH }

  scope :order_by_date, -> { order(created_at: :desc) }
  scope :most_recent, ->(number = 5) { order_by_date.include_associations.limit(number) }
  scope :include_associations, -> { includes(:commentable, :user) }

  has_paper_trail
  trackable

  def self.build_comment commentable, user, body: nil
    new(commentable: commentable, body: body, user: user)
  end
end
