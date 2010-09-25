class PublishersController < ApplicationController
  def index
    render :json => Publisher.search(params[:term]).to_json
  end
end
