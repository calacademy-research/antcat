module WikiPages
  class AutocompletesController < ApplicationController
    def show
      search_query = params[:q] || ''

      respond_to do |format|
        format.json do
          render json: Autocomplete::AutocompleteWikiPages[search_query]
        end
      end
    end
  end
end
