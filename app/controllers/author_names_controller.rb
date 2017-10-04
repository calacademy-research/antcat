# TODO more Rails.

class AuthorNamesController < ApplicationController
  before_action :authenticate_editor
  before_action :set_author_name, only: [:update, :destroy]
  before_action :set_author, only: [:create, :destroy]

  def create
    author_name = AuthorName.create author: @author, name: params[:author_name]
    author_name.touch_with_version if author_name.errors.empty?
    render_json author_name
  end

  def update
    @author_name.name = params[:author_name]
    if @author_name.save
      render_json @author_name
    else
      # TODO Not 100% true; can also fail for other reasons.
      error = { error: "Name already exists" }
      render json: error, status: :conflict
    end
  end

  # TODO move to model and use `destroy`.
  def destroy
    @author_name.delete
    # Remove the author if there are no more author names that reference it
    unless AuthorName.find_by(author_id: @author)
      @author.delete
    end
    render json: nil
  end

  private
    def set_author_name
      @author_name = AuthorName.find params[:id]
    end

    def set_author
      @author = Author.find params[:author_id]
    end

    def render_json author_name
      json = {
        content: render_to_string(partial: 'author_names/panel', locals: { author_name: author_name }),
        id: author_name.id,
        success: author_name.errors.empty?
      }
      render json: json
    end
end
