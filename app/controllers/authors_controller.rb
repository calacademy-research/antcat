# coding: UTF-8
class AuthorsController < ApplicationController
  before_filter :authenticate_user!, except: [:index]
  skip_before_filter :authenticate_user!, if: :preview?

  def index
    respond_to do |format|
      format.html {@authors = Author.sorted_by_name.paginate page: params[:page], per_page: 60}
      format.json {render json: AuthorName.search(params[:term]).to_json}
    end
  end

  def edit
    @author = Author.find params[:id]
  end

end
