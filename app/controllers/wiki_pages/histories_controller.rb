module WikiPages
  class HistoriesController < ApplicationController
    def show
      @comparer = WikiPage.revision_comparer_for params[:wiki_page_id],
        params[:selected_id], params[:diff_with_id]
    end
  end
end
