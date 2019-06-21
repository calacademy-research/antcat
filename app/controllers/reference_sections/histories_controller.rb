module ReferenceSections
  class HistoriesController < ApplicationController
    def show
      @comparer = ReferenceSection.revision_comparer_for params[:reference_section_id],
        params[:selected_id], params[:diff_with_id]
    end
  end
end
