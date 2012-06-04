# coding: UTF-8
class WidgetTestsController < ApplicationController

  def reference_picker
    @reference = Reference.first if params[:id]
  end

  def reference_field
    @taxon = Family.first
  end

  def taxt_editor
    @taxon = Family.first
  end

end
