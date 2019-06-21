module Tooltips
  class HistoriesController < ApplicationController
    def show
      @comparer = Tooltip.revision_comparer_for params[:tooltip_id],
        params[:selected_id], params[:diff_with_id]
    end
  end
end
