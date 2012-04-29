# coding: UTF-8
class WidgetTestsController < ApplicationController

  def reference_picker
  end

  def reference_field
  end

  def simulated_form
    lll {"params['Name']"}
    lll{%q{request.method}}
    head 200 if request.method == 'POST'
  end

end
