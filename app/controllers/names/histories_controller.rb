# frozen_string_literal: true

module Names
  class HistoriesController < ApplicationController
    def show
      @comparer = RevisionComparer.new(Name, params[:name_id], params[:selected_id], params[:diff_with_id])
      @revision_presenter = RevisionPresenter.new(comparer: @comparer, hide_formatted: true)
    end
  end
end
