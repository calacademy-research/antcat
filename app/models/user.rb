class User < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection

  include Feed::Trackable
  tracked on: :create,
    parameters: ->(user) do { user_id: user.id } end

  validates :name, presence: true

  scope :feedback_emails_recipients, -> { where(receive_feedback_emails: true) }
  scope :as_angle_bracketed_emails, -> { all.map(&:angle_bracketed_email).join(", ") }

  devise :database_authenticatable, :recoverable, :registerable,
         :rememberable, :trackable, :validatable, :invitable

  # For the feed. I'm not sure if this is thread-safe (and whether
  # that would be a problem), but *think* it is OK because:
  # 1) it's set in a single operation, 2) the variable is only
  # set in one place, 3) and always set to the same value or nil.
  mattr_accessor :current_user

  def can_approve_changes?
    can_edit?
  end

  def can_review_changes?
    can_edit?
  end

  def angle_bracketed_email
    %Q["#{name}" <#{email}>]
  end
end
