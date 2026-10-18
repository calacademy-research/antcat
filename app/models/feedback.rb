# frozen_string_literal: true

class Feedback < ApplicationRecord
  include Commentable
  include Trackable

  COMMENT_MAX_LENGTH = 10_000
  NAME_MAX_LENGTH = User::NAME_MAX_LENGTH
  EMAIL_MAX_LENGTH = User::EMAIL_MAX_LENGTH
  PAGE_MAX_LENGTH = 255 # Column size.

  belongs_to :user, optional: true

  # The page is filled in from the URL the visitor came from; a long URL is shortened rather than rejected.
  before_validation { self.page = page.truncate(PAGE_MAX_LENGTH, omission: '') if page }

  validates :comment, presence: true, length: { maximum: COMMENT_MAX_LENGTH }
  validates :name, length: { maximum: NAME_MAX_LENGTH }
  validates :email, length: { maximum: EMAIL_MAX_LENGTH }
  validates :page, length: { maximum: PAGE_MAX_LENGTH }
  validate :comment_has_not_previously_been_submitted, on: :create

  scope :pending, -> { where(open: true) }
  scope :by_status_and_date, -> { order(open: :desc, created_at: :desc) }
  scope :recent, -> { where('created_at >= ?', 5.minutes.ago) }

  has_paper_trail
  trackable

  def self.submitted_by_ip ip
    where(ip: ip)
  end

  def closed?
    !open?
  end

  def close!
    update!(open: false)
  end

  def reopen!
    update!(open: true)
  end

  private

    def comment_has_not_previously_been_submitted
      return unless self.class.where(comment: comment).exists?

      errors.add :comment, <<~MSG
        has already been submitted. If it is unlikely that the exact comment has already
        been submitted, please let us know. Either way, we got your feedback, thanks!.
      MSG
    end
end
