# coding: UTF-8
class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, 
         :recoverable, :rememberable, :trackable, :validatable


  attr_accessible :email, :name, :password, :password_confirmation, :can_edit, :is_superadmin, :remember_me

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
