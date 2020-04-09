# frozen_string_literal: true

class SiteNotice < ApplicationRecord
  include Commentable
  include Trackable

  TITLE_MAX_LENGTH = 100

  belongs_to :user

  validates :message, presence: true
  validates :title, presence: true, length: { maximum: TITLE_MAX_LENGTH }

  scope :most_recent_first, -> { order(created_at: :desc) }

  acts_as_readable on: :created_at
  has_paper_trail
  trackable parameters: proc { { title: title } }
end
