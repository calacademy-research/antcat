class Feedback < ActiveRecord::Base
  belongs_to :user
  validates :comment, presence: true, length: { maximum: 10_000 }

  before_save :add_emails_recipients

  scope :recently_created, ->(time_ago = 5.minutes.ago) {
    where('created_at >= :time_ago', time_ago: time_ago)
  }

  def from_the_same_ip
    Feedback.where(ip: ip)
  end

  private
    def add_emails_recipients
      self.email_recipients = User.feedback_emails_recipients
        .as_angle_bracketed_emails.presence || "sblum@calacademy.org"
    end
end
