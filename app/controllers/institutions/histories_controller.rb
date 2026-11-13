# frozen_string_literal: true

# The edit history of an institution.
#
# Routes: GET /institutions/:institution_id/history (anyone). Purpose, rights and tests of each:
# docs/catalog/routes.tsv.
module Institutions
  class HistoriesController < ApplicationController
    def show
      @comparer = RevisionComparer.new(Institution, params[:institution_id], params[:selected_id], params[:diff_with_id])
      @revision_presenter = RevisionPresenter.new(comparer: @comparer)
    end
  end
end
