class UsersController < ApplicationController
  before_action :ensure_user_is_superadmin, except: [:index, :show, :mentionables]
  before_action :set_user, only: [:show, :edit, :update, :destroy]

  def index
    @users = user_scope.order_by_name
  end

  def show
    @recent_user_activities = @user.activities.most_recent(5).includes(:user)
    @recent_user_comments = @user.comments.most_recent 5
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)

    if @user.save
      redirect_to @user, notice: "Successfully added user."
    else
      render :new
    end
  end

  def edit
  end

  def update
    if user_params[:password].present?
      @user.password = user_params[:password] # HACK.
    end

    if @user.update_without_password user_params.except(:current_password)
      redirect_to @user, notice: "Successfully updated user."
    else
      render :edit
    end
  end

  def destroy
    if @user.update(deleted: true, locked: true)
      redirect_to @user, notice: "Successfully soft-deleted and locked user."
    else
      redirect_to @user, alert: 'Could not soft-delete user.'
    end
  end

  def mentionables
    respond_to do |format|
      format.json do
        render json: User.active.all.to_json(root: false, only: [:id, :email, :name])
      end
    end
  end

  private

    def set_user
      @user = user_scope.find(params[:id])
    end

    def user_params
      params.require(:user).permit(:editor, :email, :helper, :hidden, :name, :locked, :password, :superadmin)
    end

    def user_scope
      return User.all if user_is_editor?
      User.active.non_hidden
    end
end
