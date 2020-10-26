# frozen_string_literal: true

module HistoryItems
  class HistoriesController < ApplicationController
    def show
      @comparer = RevisionComparer.new(
        HistoryItem, params[:history_item_id], params[:selected_id], params[:diff_with_id]
      )
      @revision_presenter = RevisionPresenter.new(
        comparer: @comparer,
        template: "history_items/histories/compare_revision_template"
      )
    end
  end
end
