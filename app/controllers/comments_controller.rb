class CommentsController < ApplicationController
  before_action :authenticate_editor

  def create
    @comment = Comment.build_comment commentable, current_user, comment_params[:body]

    if @comment.save
      make_child_comment
      redirect_to :back, notice: <<-MSG
        <a href="#comment-#{@comment.id}">Comment</a>
        was successfully added.
      MSG
    else
      redirect_to :back, notice: "Something went wrong. Email us?"
    end
  end

  private
    def commentable
      comment_params[:commentable_type].constantize
        .find comment_params[:commentable_id]
    end

    def make_child_comment
      return "" if comment_params[:comment_id].blank?

      parent_comment = Comment.find comment_params[:comment_id]
      @comment.move_to_child_of parent_comment
    end

    def comment_params
      params.require(:comment).permit :body, :commentable_id,
        :commentable_type, :comment_id
    end

end
