class Feedback < ActiveRecord::Base
  include Feed::Trackable

  belongs_to :user

  validates :comment, presence: true, length: { maximum: 10_000 }

  before_save :add_emails_recipients

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

  private
    def add_emails_recipients
      self.email_recipients = User.feedback_emails_recipients
        .as_angle_bracketed_emails.presence || "sblum@calacademy.org"
    end
end
