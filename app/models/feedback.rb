class Feedback < ApplicationRecord
  include Trackable

  belongs_to :user

  validates :comment, presence: true, length: { maximum: 10_000 }
  validate :comment_has_not_previously_been_submitted, on: :create

  scope :pending, -> { where(open: true) }
  scope :by_status_and_date, -> { order(open: :desc, created_at: :desc) }
  scope :recent, -> { where('created_at >= ?', 5.minutes.ago) }

  acts_as_commentable
  has_paper_trail
  trackable

  def from_the_same_ip
    self.class.where(ip: ip)
  end

  def closed?
    !open?
  end

  def close
    self.open = false
    save!
  end

  def reopen
    self.open = true
    save!
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
