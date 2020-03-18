module TaxonHistoryItems
  class HistoriesController < ApplicationController
    def show
      @comparer = RevisionComparer.new(
        TaxonHistoryItem, params[:taxon_history_item_id], params[:selected_id], params[:diff_with_id]
      )
      @revision_presenter = RevisionPresenter.new(comparer: @comparer)
    end
  end
end
