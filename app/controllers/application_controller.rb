# coding: UTF-8
class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_filter :save_location
  before_action :configure_permitted_parameters, if: :devise_controller?

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
    current_user.try(:id)
  end

  def root_redirect exception
    redirect_to root_url
  end

  # CORS protection defeat - we're read only, so this is okay.
  # This kind of thing can't stand when we have a write level API
  skip_before_filter :verify_authenticity_token

  before_filter :cors_preflight_check
  after_filter :cors_set_access_control_headers

  def cors_set_access_control_headers
    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Allow-Methods'] = 'GET'
    headers['Access-Control-Allow-Headers'] = 'Origin, Content-Type, Accept, Authorization, Token'
    headers['Access-Control-Max-Age'] = "1728000"
  end

  def cors_preflight_check
    if request.method == 'OPTIONS'
      headers['Access-Control-Allow-Origin'] = '*'
      headers['Access-Control-Allow-Methods'] = 'POST, GET, PUT, DELETE, OPTIONS'
      headers['Access-Control-Allow-Headers'] = 'X-Requested-With, X-Prototype-Version, Token'
      headers['Access-Control-Max-Age'] = '1728000'

      render :text => '', :content_type => 'text/plain'
    end
  end

  # end CORS

  protected
    def configure_permitted_parameters
      devise_parameter_sanitizer.for(:sign_up) { |u| u.permit(:username, :email, :password, :password_confirmation, :remember_me) }
      devise_parameter_sanitizer.for(:sign_in) { |u| u.permit(:login, :username, :email, :password, :remember_me) }
      devise_parameter_sanitizer.for(:account_update) { |u| u.permit(:username, :email, :name, :password, :password_confirmation, :current_password) }
    end
end