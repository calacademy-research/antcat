class BoltonMatchesController < ApplicationController
  def index
    @references = params[:confidence] ? Bolton::Reference.with_confidence(params[:confidence].to_i) :
                                        Bolton::Reference.all
    @references = @references.paginate :page => params[:page]
  end
end
