module TaxonHistoryItems
  class HistoriesController < ApplicationController
    def show
      @comparer = TaxonHistoryItem.revision_comparer_for params[:taxon_history_item_id],
        params[:selected_id], params[:diff_with_id]
    end
  end
end
