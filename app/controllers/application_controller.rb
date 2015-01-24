# coding: UTF-8
class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :save_location

  def preview?
    $Milieu.preview?
  end

  def save_location
    session[:user_return_to] = request.url unless request.url =~ %r{/users/}
  end

  def send_back_json hash
    json = hash.to_json
    json = '<textarea>' + json + '</textarea>' unless params[:picker].present? || params[:popup].present? || params[:field].present? || Rails.env.test?
    render json: json, content_type: 'text/html'
  end

  def authenticate_editor
    authenticate_user! && $Milieu.user_can_edit?(current_user)
  end

  def user_for_paper_trail
    unless current_user.nil?
      return current_user.id
    end
    nil
  end


end
