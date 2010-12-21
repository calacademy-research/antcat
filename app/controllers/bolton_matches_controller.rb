class BoltonMatchesController < ApplicationController
  def index
    @references = Bolton::Reference.all.paginate
  end
end
