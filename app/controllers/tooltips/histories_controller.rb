# frozen_string_literal: true

# The edit history of a tooltip.
#
# Routes: GET /tooltips/:tooltip_id/history (anyone). Purpose, rights and tests of each: docs/catalog/routes.tsv.
module Tooltips
  class HistoriesController < ApplicationController
    def show
      @comparer = RevisionComparer.new(Tooltip, params[:tooltip_id], params[:selected_id], params[:diff_with_id])
      @revision_presenter = RevisionPresenter.new(comparer: @comparer)
    end
  end
end
