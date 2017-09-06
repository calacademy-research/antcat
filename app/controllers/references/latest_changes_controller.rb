module References
  class LatestChangesController < ApplicationController
    layout "references"

    def index
      @references = Reference.latest_changes
        .includes_document.paginate(page: params[:page])
    end
  end
end
