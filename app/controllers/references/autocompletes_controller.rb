# frozen_string_literal: true

module References
  class AutocompletesController < ApplicationController
    def show
      render json: serialized_references
    end

    private

      def serialized_references
        search_query = params[:reference_q] || ''
        Autocomplete::ReferencesQuery[search_query]
      end
  end
end
