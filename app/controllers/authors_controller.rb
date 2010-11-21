class AuthorsController < ApplicationController
  def index
    render :json => AuthorName.search(params[:term]).to_json
  end
end
