class BoltonMatchesController < ApplicationController
  def index
    @references = Bolton::Reference.with_possible_matches.paginate :page => params[:page], :per_page => 600
  end
end
