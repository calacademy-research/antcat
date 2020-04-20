# frozen_string_literal: true

module References
  class LatestChangesController < ApplicationController
    def index
      @references = ReferenceQuery.new.latest_changes.includes(:document).paginate(page: params[:page])
    end
  end
end
