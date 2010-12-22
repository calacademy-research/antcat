class BoltonMatchesController < ApplicationController
  def index
    @references = Bolton::Reference.all.paginate :page => params[:page]
  end
end
