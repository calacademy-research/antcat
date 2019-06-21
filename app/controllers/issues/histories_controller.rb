module Issues
  class HistoriesController < ApplicationController
    def show
      @comparer = Issue.revision_comparer_for params[:issue_id],
        params[:selected_id], params[:diff_with_id]
    end
  end
end
