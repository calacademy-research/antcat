class Feedback < ApplicationRecord
  include Commentable
  include Trackable

  COMMENT_MAX_LENGTH = 10_000

  belongs_to :user

  validates :comment, presence: true, length: { maximum: COMMENT_MAX_LENGTH }
  validate :comment_has_not_previously_been_submitted, on: :create

  scope :pending, -> { where(open: true) }
  scope :by_status_and_date, -> { order(open: :desc, created_at: :desc) }
  scope :recent, -> { where('created_at >= ?', 5.minutes.ago) }

  acts_as_commentable
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
