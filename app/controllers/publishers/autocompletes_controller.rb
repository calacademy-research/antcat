module Publishers
  class AutocompletesController < ApplicationController
    def show
      render json: Autocomplete::AutocompletePublishers[params[:term]]
    end
  end
end
