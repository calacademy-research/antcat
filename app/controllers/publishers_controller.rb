class PublishersController < ApplicationController
  def index
    render json: Publisher.search(params[:term])
  end
end
