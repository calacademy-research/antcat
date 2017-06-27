module Catalog
  class HistoryController < ApplicationController
    def show
      @comparer = Taxon.revision_comparer_for params[:id],
        params[:selected_id], params[:diff_with_id]
    end
  end
end
