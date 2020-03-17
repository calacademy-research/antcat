module Tooltips
  class HistoriesController < ApplicationController
    def show
      @comparer = RevisionComparer.new(Tooltip, params[:tooltip_id], params[:selected_id], params[:diff_with_id])
      @revision_presenter = RevisionPresenter.new(comparer: @comparer, hide_formatted: true)
    end
  end
end
