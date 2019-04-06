module Names
  class HistoryController < ApplicationController
    def index
      @comparer = Name.revision_comparer_for params[:name_id],
        params[:selected_id], params[:diff_with_id]
    end
  end
end
