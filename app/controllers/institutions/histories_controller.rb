module Institutions
  class HistoriesController < ApplicationController
    def show
      @comparer = RevisionComparer.new(Institution, params[:institution_id], params[:selected_id], params[:diff_with_id])
      @revision_presenter = RevisionPresenter.new(
        comparer: @comparer,
        template: "institutions/histories/compare_revision_template"
      )
    end
  end
end
