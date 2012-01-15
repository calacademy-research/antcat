# coding: UTF-8
class AuthorsController < ApplicationController
  def index
    respond_to do |format|
      format.json {render :json => AuthorName.search(params[:term]).to_json}
      format.html
    end
  end
end
