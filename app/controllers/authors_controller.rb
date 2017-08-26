class AuthorsController < ApplicationController
  before_action :authenticate_editor, except: [:index, :show, :autocomplete]
  before_action :set_author, only: [:show, :edit]
  layout "references"

  def index
    @authors = Author.sorted_by_name.paginate(page: params[:page], per_page: 60)
  end

  def show
  end

  def edit
  end

  def autocomplete
    respond_to do |format|
      format.json do
        render json: Autocomplete::AuthorNames.new(params[:term]).call
      end
    end
  end

  private
    def set_author
      @author = Author.find params[:id]
    end
end
