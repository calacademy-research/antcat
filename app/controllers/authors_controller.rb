# coding: UTF-8
class AuthorsController < ApplicationController

  def index
    params[:q].strip! if params[:q]
    @authors = []
    @authors = Author.find_by_names [params[:q]] if params[:q].present?
  end

  def all
    respond_to do |format|
      format.json {render :json => AuthorName.search(params[:term]).to_json}
      format.html
    end
  end
end
