# coding: UTF-8
class ApplicationController < ActionController::Base
  helper :all
  protect_from_forgery
  before_filter :save_location

  def preview?
    $ReleaseType.preview?
  end

  def save_location
    session[:user_return_to] = request.url unless request.url =~ %r{/users/}
  end

end
