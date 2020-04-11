# frozen_string_literal: true

module WikiPages
  class AutocompletesController < ApplicationController
    def show
      search_query = params[:q] || ''

      respond_to do |format|
        format.json do
          render json: Autocomplete::AutocompleteWikiPages[search_query].to_json(root: false, only: [:id, :title])
        end
      end
    end
  end
end
