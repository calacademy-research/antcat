class UsersController < ApplicationController
  before_action :authenticate_editor, except: [:index]

  def index
    @users = User.order_by_name
  end

  def emails
    @editor_emails = User.editors.order_by_name.as_angle_bracketed_emails
    @non_editor_emails = User.non_editors.order_by_name.as_angle_bracketed_emails
    @all = "#{@editor_emails}, #{@non_editor_emails}"
  end
end
