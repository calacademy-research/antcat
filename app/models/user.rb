class User < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection

  devise :database_authenticatable, :recoverable, :registerable,
         :rememberable, :trackable, :validatable, :invitable

  validates :name, presence: true

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

end
