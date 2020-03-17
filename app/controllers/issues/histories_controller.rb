module Issues
  class HistoriesController < ApplicationController
    def show
      @comparer = RevisionComparer.new(Issue, params[:issue_id], params[:selected_id], params[:diff_with_id])
      @revision_presenter = RevisionPresenter.new(comparer: @comparer)
    end
  end
end
