# frozen_string_literal: true

# The edit history of a reference.
#
# Routes: GET /references/:reference_id/history (anyone). Purpose, rights and tests of each:
# docs/catalog/routes.tsv.
module References
  class HistoriesController < ApplicationController
    def show
      @comparer = RevisionComparer.new(Reference, params[:reference_id], params[:selected_id], params[:diff_with_id])
      @revision_presenter = RevisionPresenter.new(comparer: @comparer)
    end
  end
end
