# frozen_string_literal: true

module WikiPages
  class HistoriesController < ApplicationController
    def show
      @comparer = RevisionComparer.new(WikiPage, params[:wiki_page_id], params[:selected_id], params[:diff_with_id])
      @revision_presenter = RevisionPresenter.new(
        comparer: @comparer,
        template: "wiki_pages/histories/compare_revision_template"
      )
    end
  end
end
