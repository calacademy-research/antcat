# frozen_string_literal: true

module References
  class LatestChangesController < ApplicationController
    def index
      @references = Reference.latest_changes.includes(:document).paginate(page: params[:page])
    end
  end
end
