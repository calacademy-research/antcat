class PublishersController < ApplicationController
  def autocomplete
    render json: Autocomplete::AutocompletePublishers[params[:term]]
  end
end
