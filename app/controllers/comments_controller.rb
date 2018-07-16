class CommentsController < ApplicationController
  include HasWhereFilters

  before_action :authenticate_editor
  before_action :set_comment, only: [:edit, :update]

  has_filters(
    user_id: {
      tag: :select_tag,
      options: -> { User.order(:name).pluck(:name, :id) }
    },
    commentable_type: {
      tag: :select_tag,
      options: -> { Comment.distinct.pluck(:commentable_type) }
    },
    commentable_id: {
      tag: :number_field_tag
    }
  )

  def index
    @comments = Comment.filter(filter_params)
    @comments = @comments.order_by_date.paginate(page: params[:page])
  end

  def create
    @comment = Comment.build_comment commentable, current_user, comment_params[:body]
    @comment.set_parent_to = comment_params[:comment_id]

    if @comment.save
      highlighted_comment_url = "#{request.referer}#comment-#{@comment.id}"
      redirect_to highlighted_comment_url, notice: <<-MSG
        <a href="#comment-#{@comment.id}">Comment</a>
        was successfully added.
      MSG
    else
      # TODO add proper error messages.
      redirect_back fallback_location: root_path, notice: "Something went wrong. Email us?"
    end
  end

  def edit
  end

  def update
    unless @comment.user == current_user
      # It's only possible to get here if a user is logged in, starts editing
      # a comment, logs in as another user, and then tries to save.
      render action: :edit, notice: "You can only edit your own comments."
      return
    end

    @comment.body = comment_params[:body]
    @comment.edited = true

    if @comment.save
      redirect_to @comment.commentable, notice: <<-MSG
        <a href="#comment-#{@comment.id}">Comment</a> was successfully updated.
      MSG
    else
      render :edit
    end
  end

  private

    def set_comment
      @comment = Comment.find params[:id]
    end

    def commentable
      comment_params[:commentable_type].constantize
        .find comment_params[:commentable_id]
    end

    def comment_params
      params.require(:comment).permit :body, :commentable_id,
        :commentable_type, :comment_id
    end
end
