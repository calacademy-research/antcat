# frozen_string_literal: true

class Comment < ApplicationRecord
  include Trackable

  BODY_MAX_LENGTH = 100_000
  # Comments on these are only shown to helpers and above (Feedback is helper-only).
  HELPER_ONLY_COMMENTABLE_TYPES = %w[Feedback].freeze

  belongs_to :commentable, polymorphic: true
  belongs_to :user

  validates :body, presence: true, length: { maximum: BODY_MAX_LENGTH }

  scope :most_recent_first, -> { order(id: :desc) }
  scope :include_associations, -> { includes(:commentable, :user) }
  scope :visible_to, ->(user) do
    user&.at_least_helper? ? all : where.not(commentable_type: HELPER_ONLY_COMMENTABLE_TYPES)
  end

  has_paper_trail
  trackable

  def self.build_comment commentable, user, body: nil
    new(commentable: commentable, body: body, user: user)
  end
end
