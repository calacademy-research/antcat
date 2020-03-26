# frozen_string_literal: true

module Protonyms
  class AutocompletesController < ApplicationController
    def show
      search_query = params[:qq] || ''

      respond_to do |format|
        format.json do
          render json: Autocomplete::AutocompleteProtonyms[search_query]
        end
      end
    end
  end
end
