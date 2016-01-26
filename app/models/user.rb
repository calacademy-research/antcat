class User < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection

  devise :database_authenticatable, :recoverable, :registerable,
         :rememberable, :trackable, :validatable, :invitable

  def is_editor?
    can_edit
  end

  def can_approve_changes?
    can_edit
  end

  def can_review_changes?
    can_edit
  end

  def is_superadmin?
    is_superadmin
  end

end
