class User < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection

  devise :database_authenticatable, :recoverable, :registerable,
         :rememberable, :trackable, :validatable, :invitable

  def can_approve_changes?
    can_edit?
  end

  def can_review_changes?
    can_edit?
  end

  def can_upload_pdfs?
    can_edit?
  end

end
