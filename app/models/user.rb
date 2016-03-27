class User < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection

  scope :feedback_emails_recipients, -> { where(receive_feedback_emails: true) }

  devise :database_authenticatable, :recoverable, :registerable,
         :rememberable, :trackable, :validatable, :invitable

  validates :name, presence: true

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
