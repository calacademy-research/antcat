# coding: UTF-8
class WidgetTestsController < ApplicationController

  def name_picker
  end

  def reference_picker_test
    @reference = Reference.first if params[:id]
  end

  def reference_field
  end

  def name_field
  end

  def taxt_editor
    @taxon = Family.first
  end

  def taxon_form_test
    @taxon = Genus.first
  end

end
