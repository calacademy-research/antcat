class CommentsController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_unconfirmed_user_is_not_over_edit_limit, except: [:index]
  before_action :set_comment, only: [:edit, :update]

  def index
    @comments = if params[:user_id]
                  Comment.where(user_id: params[:user_id])
                else
                  Comment.all
                end
    @comments = @comments.order_by_date.include_associations.paginate(page: params[:page])
  end

  def create
    @comment = Comment.build_comment commentable, current_user, body: comment_params[:body]

    if @comment.save
      @comment.create_activity :create, current_user
      @comment.notify_relevant_users
      highlighted_comment_url = "#{request.referer}#comment-#{@comment.id}"
      redirect_to highlighted_comment_url, notice: <<-MSG
        <a href="#comment-#{@comment.id}">Comment</a> was successfully added.
      MSG
    else
      redirect_back fallback_location: root_path, notice: "Something went wrong. Email us?"
    end
  end

  def edit
  end

  def update
    if @comment.update(body: comment_params[:body], edited: true)
      @comment.notify_relevant_users
      redirect_to @comment.commentable, notice: <<-MSG
        <a href="#comment-#{@comment.id}">Comment</a> was successfully updated.
      MSG
    else
      render :edit
    end
  end

  private

    def set_comment
      @comment = current_user.comments.find(params[:id])
    end

    def comment_params
      params.require(:comment).permit(:body, :commentable_id, :commentable_type)
    end

    def commentable
      comment_params[:commentable_type].constantize.find(comment_params[:commentable_id])
    end
end
