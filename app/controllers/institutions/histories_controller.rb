module Institutions
  class HistoriesController < ApplicationController
    def show
      @comparer = Institution.revision_comparer_for params[:institution_id],
        params[:selected_id], params[:diff_with_id]
      @revision_presenter = RevisionPresenter.new(comparer: @comparer)
    end
  end
end
