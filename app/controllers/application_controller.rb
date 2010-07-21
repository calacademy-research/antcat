class ApplicationController < ActionController::Base
  layout nil
  helper :all
  protect_from_forgery
end
