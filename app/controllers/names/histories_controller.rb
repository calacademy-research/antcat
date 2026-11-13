# frozen_string_literal: true

# The edit history of a name.
#
# Routes: GET /names/:name_id/history (anyone). Purpose, rights and tests of each: docs/catalog/routes.tsv.
module Names
  class HistoriesController < ApplicationController
    def show
      @comparer = RevisionComparer.new(Name, params[:name_id], params[:selected_id], params[:diff_with_id])
      @revision_presenter = RevisionPresenter.new(comparer: @comparer)
    end
  end
end
