class AuthorsController < ApplicationController
  before_action :authenticate_editor, except: [:index, :autocomplete]
  layout "references"

  def index
    @authors = Author.sorted_by_name.paginate(page: params[:page], per_page: 60)
  end

  def edit
    @author = Author.find params[:id]
  end

  def autocomplete
    respond_to do |format|
      format.json do
        render json: AuthorName.search(params[:term])
      end
    end
  end
end
