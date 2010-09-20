class AuthorsController < ApplicationController
  def index
    render :json => Author.search(params[:term]).to_json
  end
end
