# frozen_string_literal: true

module References
  class LinkableAutocompletesController < ApplicationController
    # For at.js. Not as advanced as `References::AutocompletesController`.
    def show
      search_query = params[:q] || ''

      respond_to do |format|
        format.json do
          render json: Autocomplete::AutocompleteLinkableReferences[search_query]
        end
      end
    end
  end
end
