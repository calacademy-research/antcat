# coding: UTF-8
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
  end

  def taxt_editor_test
    @taxon = Family.first
  end

end
