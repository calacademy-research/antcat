# TODO rename to TestsController?
class WidgetTestsController < ApplicationController
  def name_popup_test
  end

  def reference_field_test
    @reference = Reference.first if params[:id]
  end

  def reference_popup_test
    @reference = Reference.first if params[:id]
  end

  def name_field_test
    @name = Name.first if params[:id]
    @default_name_string = 'Eciton'
  end

  def taxt_editor_test
    @taxon = Family.first
  end

  def tooltips_test
  end

  def toggle_dev_css
    session[:no_dev_css] = !session[:no_dev_css]
    redirect_to :back
  end
end
