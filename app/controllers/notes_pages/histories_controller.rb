# frozen_string_literal: true

# The edit history of the page of notes on a name.
#
# Routes: GET /notes_pages/:notes_page_id/history (anyone). Purpose, rights and tests of each:
# docs/catalog/routes.tsv.
module NotesPages
  class HistoriesController < ApplicationController
    def show
      @comparer = RevisionComparer.new(NotesPage, params[:notes_page_id], params[:selected_id], params[:diff_with_id])
      @revision_presenter = RevisionPresenter.new(
        comparer: @comparer,
        template: "notes_pages/histories/compare_revision_template"
      )
    end
  end
end
