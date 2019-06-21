module References
  class HistoriesController < ApplicationController
    def show
      @comparer = Reference.revision_comparer_for params[:reference_id],
        params[:selected_id], params[:diff_with_id]
    end
  end
end
