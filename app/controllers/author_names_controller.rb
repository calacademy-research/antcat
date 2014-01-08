# coding: UTF-8
class AuthorNamesController < ApplicationController
  before_filter :authenticate_editor
  skip_before_filter :authenticate_editor, if: :preview?

  def update
    @author_name = AuthorName.find params[:id]
    @author_name.name = params[:author_name]
    @author_name.save!
    render_json false
  end

  def create
    author = Author.find params[:author_id]
    @author_name = AuthorName.create author: author, name: params[:author_name]
    render_json true
  end

  ###
  def render_json is_new
    json = {
      isNew: is_new,
      content: render_to_string(partial: 'author_names/panel', locals: {author_name: @author_name}),
      id: @author_name.id,
      success: @author_name.errors.empty?
    }.to_json

    render json: json, content_type: 'text/html'
  end

end
