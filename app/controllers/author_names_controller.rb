class AuthorNamesController < ApplicationController
  before_action :ensure_can_edit_catalog
  before_action :authenticate_superadmin, only: [:destroy]
  before_action :set_author_name, only: [:update, :edit, :destroy]
  before_action :set_author, only: [:new, :create]

  def new
    @author_name = AuthorName.new author: @author
  end

  def create
    @author_name = AuthorName.new author: @author
    @author_name.attributes = author_name_params

    if @author_name.save
      redirect_to @author_name.author, notice: 'Author name was successfully created.'
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @author_name.update author_name_params
      redirect_to @author_name.author, notice: 'Author name was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    if @author_name.destroy
      redirect_to @author_name.author, notice: 'Author name was successfully deleted.'
    else
      redirect_to @author_name.author, alert: 'Could not delete author name.'
    end
  end

  private

    def set_author_name
      @author_name = AuthorName.find params[:id]
    end

    def set_author
      @author = Author.find params[:author_id]
    end

    def author_name_params
      params.require(:author_name).permit(:name)
    end
end
