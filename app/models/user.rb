# coding: UTF-8
class User < ActiveRecord::Base
  devise :database_authenticatable, :recoverable, :registerable,
         :rememberable, :trackable, :validatable, :invitable

  attr_accessible :email, :name, :password, :password_confirmation, :can_edit_catalog, :can_approve_changes

  def is_editor?
    true
  end

end
