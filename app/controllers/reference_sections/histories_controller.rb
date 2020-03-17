module ReferenceSections
  class HistoriesController < ApplicationController
    def show
      @comparer = RevisionComparer.new(
        ReferenceSection, params[:reference_section_id], params[:selected_id], params[:diff_with_id]
      )
      @revision_presenter = RevisionPresenter.new(comparer: @comparer)
    end
  end
end
