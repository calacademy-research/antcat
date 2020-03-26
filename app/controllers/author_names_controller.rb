# frozen_string_literal: true

class AuthorNamesController < ApplicationController
  before_action :ensure_user_is_editor

  def new
    @author = find_author
    @author_name = AuthorName.new(author: @author)
  end

  def create
    @author = find_author
    @author_name = AuthorName.new(author: @author)
    @author_name.attributes = author_name_params

    if @author_name.save
      @author_name.create_activity :create, current_user, edit_summary: params[:edit_summary]
      redirect_to @author_name.author, notice: 'Author name was successfully created.'
    else
      render :new
    end
  end

  def edit
    @author_name = find_author_name
  end

  def update
    @author_name = find_author_name

    if @author_name.update(author_name_params)
      @author_name.create_activity :update, current_user, edit_summary: params[:edit_summary]
      redirect_to @author_name.author, notice: 'Author name was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    author_name = find_author_name

    if author_name.destroy
      author_name.create_activity :destroy, current_user
      redirect_to author_name.author, notice: 'Author name was successfully deleted.'
    else
      redirect_to author_name.author, alert: 'Could not delete author name.'
    end
  end

  private

    def find_author_name
      AuthorName.find(params[:id])
    end

    def find_author
      Author.find(params[:author_id])
    end

    def author_name_params
      params.require(:author_name).permit(:name)
    end
end
