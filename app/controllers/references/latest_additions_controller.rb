# frozen_string_literal: true

# References added most recently.
#
# Routes: GET /references/latest_additions (anyone). Purpose, rights and tests of each: docs/catalog/routes.tsv.
module References
  class LatestAdditionsController < ApplicationController
    def index
      @references = ReferenceQuery.new.latest_additions.includes(:document).paginate(page: params[:page])
    end
  end
end
