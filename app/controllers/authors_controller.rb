class AuthorsController < ApplicationController
  before_filter :authenticate_user!, except: [:index]
  skip_before_filter :authenticate_user!, if: :preview?

  def index
    respond_to do |format|
      format.html do
        @authors = Author.sorted_by_name.paginate(page: params[:page], per_page: 60)
      end
      format.json do
        render json: AuthorName.search(params[:term])
      end
    end
  end

  def edit
    @author = Author.find params[:id]
  end

end
