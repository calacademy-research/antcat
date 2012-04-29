# coding: UTF-8
class WidgetTestsController < ApplicationController

  def reference_picker
  end

  def reference_field
  end

  def nested_form
    lll params['Name']
    head 200 if request.method == 'POST'
  end

end
