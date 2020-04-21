# frozen_string_literal: true

module References
  class LinkableAutocompletesController < ApplicationController
    # For at.js. Not as advanced as `References::AutocompletesController`.
    def show
      respond_to do |format|
        format.json do
          render json: serialized_references
        end
      end
    end

    private

      def serialized_references
        Autocomplete::LinkableReferencesSerializer[references]
      end

      def references
        search_query = params[:q] || ''
        Autocomplete::LinkableReferencesQuery[search_query]
      end
  end
end
