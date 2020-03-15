module Names
  class HistoriesController < ApplicationController
    def show
      @comparer = Name.revision_comparer_for params[:name_id],
        params[:selected_id], params[:diff_with_id]
      @revision_presenter = RevisionPresenter.new(comparer: @comparer)
    end
  end
end
