# coding: UTF-8
class AuthorNamesController < ApplicationController
  before_filter :authenticate_editor
  skip_before_filter :authenticate_editor, if: :preview?

  def update
    @author_name = AuthorName.find params[:id]
    @author_name.name = params[:author_name]
    begin
      @author_name.save!
    rescue ActiveRecord::RecordInvalid => invalid
      err={'error' => "Name already exists"}
      render :json => err.to_json, :status => 409
      return
    end

    render_json false
  end

  def create
    author = Author.find params[:author_id]

    @author_name = AuthorName.create author: author, name: params[:author_name]
    if @author_name.errors.empty?
      @author_name.touch_with_version
    end

    render_json true
  end

  # From URL: : "/authors/11282/author_names/194557"
  # Params are "author_id"(11282) and "id" (194557) (The latter links to author_names)

  def destroy
    author = Author.find params[:author_id]
    author_name = AuthorName.find params[:id]
    author_name.delete
    # Remove the author if there are no more author names that reference it
    if AuthorName.find_by_author_id(params[:author_id]).nil?
      author.delete
    end



    render json: nil, content_type: 'text/html'
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
