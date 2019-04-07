class WidgetTestsController < ApplicationController
  def toggle_dev_css
    session[:no_dev_css] = !session[:no_dev_css]
    redirect_back fallback_location: root_path
  end
end
