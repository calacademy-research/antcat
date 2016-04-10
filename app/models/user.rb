class User < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection

  validates :name, presence: true

  scope :feedback_emails_recipients, -> { where(receive_feedback_emails: true) }
  scope :as_angle_bracketed_emails, -> { all.map(&:angle_bracketed_email).join(", ") }

  devise :database_authenticatable, :recoverable, :registerable,
         :rememberable, :trackable, :validatable, :invitable

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
