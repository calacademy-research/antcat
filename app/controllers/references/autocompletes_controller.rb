# frozen_string_literal: true

module References
  class AutocompletesController < ApplicationController
    def show
      search_query = params[:reference_q] || ''

      respond_to do |format|
        format.json do
          render json: Autocomplete::AutocompleteReferences[search_query]
        end
      end
    end
  end
end
