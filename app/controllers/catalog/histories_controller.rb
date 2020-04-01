# frozen_string_literal: true

module Catalog
  class HistoriesController < ApplicationController
    def show
      @comparer = RevisionComparer.new(Taxon, params[:id], params[:selected_id], params[:diff_with_id])
      @revision_presenter = RevisionPresenter.new(comparer: @comparer)
    end
  end
end
