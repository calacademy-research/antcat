module Journals
  class AutocompletesController < ApplicationController
    def show
      search_query = params[:term] || '' # TODO: Standardize all "q/qq/query/term".

      respond_to do |format|
        format.json { render json: Autocomplete::AutocompleteJournals[search_query] }
      end
    end
  end
end
