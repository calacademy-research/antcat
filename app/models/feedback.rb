class Feedback < ActiveRecord::Base
  belongs_to :user
  validates :comment, presence: true

  scope :recently_created, ->(time_ago = 5.minutes.ago) {
    where('created_at >= :time_ago', time_ago: time_ago)
  }

  def from_the_same_ip
    Feedback.where(ip: ip)
  end

end
