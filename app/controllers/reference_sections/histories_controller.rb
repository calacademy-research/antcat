# frozen_string_literal: true

module ReferenceSections
  class HistoriesController < ApplicationController
    def show
      @comparer = RevisionComparer.new(
        ReferenceSection, params[:reference_section_id], params[:selected_id], params[:diff_with_id]
      )
      @revision_presenter = RevisionPresenter.new(
        comparer: @comparer,
        template: "reference_sections/histories/compare_revision_template"
      )
    end
  end
end
