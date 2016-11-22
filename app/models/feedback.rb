# TODO remove `feedbacks.email_recipients`.

class Feedback < ActiveRecord::Base
  include Feed::Trackable

  belongs_to :user

  validates :comment, presence: true, length: { maximum: 10_000 }

  scope :pending, -> { where(open: true) }
  scope :recently_created, ->(time_ago = 5.minutes.ago) {
    where('created_at >= ?', time_ago)
  }

  acts_as_commentable
  has_paper_trail
  tracked on: [:create, :destroy]

  def from_the_same_ip
    Feedback.where(ip: ip)
  end

  def closed?
    !open?
  end

  def close
    self.open = false
    save!
    create_activity :close_feedback
  end

  def reopen
    self.open = true
    save!
    create_activity :reopen_feedback
  end
end
