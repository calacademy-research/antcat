class BoltonMatchesController < ApplicationController
  def index
    @references = Bolton::Reference.with_confidence(81).paginate :page => params[:page]
  end
end
