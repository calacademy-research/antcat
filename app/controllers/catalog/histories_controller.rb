# frozen_string_literal: true

# The edit history of a taxon.
#
# Routes: GET /catalog/:id/history (anyone). Purpose, rights and tests of each: docs/catalog/routes.tsv.
module Catalog
  class HistoriesController < ApplicationController
    def show
      @comparer = RevisionComparer.new(Taxon, params[:id], params[:selected_id], params[:diff_with_id])
      @revision_presenter = RevisionPresenter.new(comparer: @comparer)
    end
  end
end
