class CommentsController < ApplicationController
  before_action :authenticate_editor

  def index
    @comments = Comment.order_by_date.paginate(page: params[:page])
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
      redirect_to :back, notice: "Something went wrong. Email us?"
    end
  end

  private
    def commentable
      comment_params[:commentable_type].constantize
        .find comment_params[:commentable_id]
    end

    def comment_params
      params.require(:comment).permit :body, :commentable_id,
        :commentable_type, :comment_id
    end
end
