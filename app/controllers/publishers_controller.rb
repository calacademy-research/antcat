class PublishersController < ApplicationController
  def autocomplete
    render json: Autocomplete::Publishers.new(params[:term]).call
  end
end
