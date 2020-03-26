# frozen_string_literal: true

module References
  class HistoriesController < ApplicationController
    def show
      @comparer = RevisionComparer.new(Reference, params[:reference_id], params[:selected_id], params[:diff_with_id])
      @revision_presenter = RevisionPresenter.new(
        comparer: @comparer,
        template: "references/histories/compare_revision_template"
      )
    end
  end
end
