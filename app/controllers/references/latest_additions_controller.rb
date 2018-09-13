module References
  class LatestAdditionsController < ApplicationController
    layout "references"

    def index
      @references = Reference.latest_additions.includes_document.paginate(page: params[:page])
    end
  end
end
