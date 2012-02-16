# coding: UTF-8
class ApplicationController < ActionController::Base
  helper :all
  protect_from_forgery

  def preview?
    $ReleaseType.preview?
  end

end
