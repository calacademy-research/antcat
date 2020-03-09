module Publishers
  class AutocompletesController < ApplicationController
    def show
      render json: Autocomplete::AutocompletePublishers[params[:term]].map(&:display_name)
    end
  end
end
