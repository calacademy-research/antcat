# frozen_string_literal: true

module Protonyms
  class HistoriesController < ApplicationController
    def show
      @comparer = RevisionComparer.new(Protonym, params[:protonym_id], params[:selected_id], params[:diff_with_id])
      @revision_presenter = RevisionPresenter.new(comparer: @comparer)
    end
  end
end
