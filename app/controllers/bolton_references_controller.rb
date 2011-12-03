# coding: UTF-8
class BoltonReferencesController < ApplicationController

  def index
    @references = Bolton::Reference.paginate :page => params[:page]
  end

end
