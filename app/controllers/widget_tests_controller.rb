class WidgetTestsController < ApplicationController
  def name_field_test
    @name = Name.first if params[:id]
    @default_name_string = 'Eciton'
  end

  def tooltips_test
  end

  def toggle_dev_css
    session[:no_dev_css] = !session[:no_dev_css]
    redirect_back fallback_location: root_path
  end
end
