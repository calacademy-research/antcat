class Feedback < ActiveRecord::Base
  belongs_to :user
  validates :comment, presence: true
end
