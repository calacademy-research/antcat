class PublishersController < ApplicationController
  def autocomplete
    render json: Autocomplete::Publishers[params[:term]]
  end
end
