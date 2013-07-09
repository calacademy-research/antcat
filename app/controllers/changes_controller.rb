# coding: UTF-8
class ChangesController < ApplicationController
  before_filter :authenticate_catalog_editor
  skip_before_filter :authenticate_catalog_editor, if: :preview?

  def index
    render nothing: true
  end

end
