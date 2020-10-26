# frozen_string_literal: true

module TaxonHistoryItems
  class HistoriesController < ApplicationController
    def show
      @comparer = RevisionComparer.new(
        HistoryItem, params[:taxon_history_item_id], params[:selected_id], params[:diff_with_id]
      )
      @revision_presenter = RevisionPresenter.new(
        comparer: @comparer,
        template: "taxon_history_items/histories/compare_revision_template"
      )
    end
  end
end
