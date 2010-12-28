class BoltonMatchesController < ApplicationController
  def index
    @references = Bolton::Reference.with_possible_matches.paginate :page => params[:page]
  end
end
