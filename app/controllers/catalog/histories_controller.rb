module Catalog
  class HistoriesController < ApplicationController
    def show
      @comparer = Taxon.revision_comparer_for params[:id],
        params[:selected_id], params[:diff_with_id]
      @revision_presenter = RevisionPresenter.new(comparer: @comparer, hide_formatted: true)
    end
  end
end
