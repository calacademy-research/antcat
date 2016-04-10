class PublishersController < ApplicationController
  def autocomplete
    render json: Publisher.search(params[:term])
  end
end
