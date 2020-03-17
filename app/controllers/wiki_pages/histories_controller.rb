module WikiPages
  class HistoriesController < ApplicationController
    def show
      @comparer = RevisionComparer.new(WikiPage, params[:wiki_page_id], params[:selected_id], params[:diff_with_id])
      @revision_presenter = RevisionPresenter.new(comparer: @comparer)
    end
  end
end
