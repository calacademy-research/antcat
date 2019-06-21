module References
  class LatestAdditionsController < ApplicationController
    def index
      @references = Reference.latest_additions.includes(:document).paginate(page: params[:page])
    end
  end
end
