# frozen_string_literal: true

# References changed most recently.
#
# Routes: GET /references/latest_changes (anyone). Purpose, rights and tests of each: docs/catalog/routes.tsv.
module References
  class LatestChangesController < ApplicationController
    def index
      @references = ReferenceQuery.new.latest_changes.includes(:document).paginate(page: params[:page])
    end
  end
end
