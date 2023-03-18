# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :ensure_user_is_superadmin, except: [:index, :show, :mentionables]

  def index
    @active_users = User.active.non_hidden.order_by_name
    @show_user_stats = current_user&.superadmin? && params[:show_user_stats] # TODO: Secret hidden param.

    if user_is_at_least_helper?
      @hidden_users = User.hidden.order_by_name
    end

    if user_is_superadmin?
      @deleted_or_locked_users = User.deleted_or_locked.order_by_name
    end
  end

  def show
    @user = find_user
    @recent_user_activities = @user.activities.most_recent_first.limit(5).includes(:user)
    @recent_user_comments = @user.comments.most_recent_first.limit(5)
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)

    if @user.save
      redirect_to @user, notice: "Successfully added user."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @user = find_user
  end

  def update
    @user = find_user
    if user_params[:password].present?
      @user.password = user_params[:password] # HACK.
    end

    if @user.update_without_password user_params.except(:current_password)
      redirect_to @user, notice: "Successfully updated user."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    user = find_user

    if user.update(deleted: true, locked: true)
      redirect_to user, notice: "Successfully soft-deleted and locked user."
    else
      redirect_to user, alert: 'Could not soft-delete user.'
    end
  end

  def mentionables
    respond_to do |format|
      format.json do
        render json: User.active.all.to_json(only: [:id, :email, :name])
      end
    end
  end

  private

    def find_user
      user_scope.find(params[:id])
    end

    def user_params
      params.require(:user).permit(
        :editor, :email, :author_id, :enable_email_notifications,
        :helper, :hidden, :name, :locked, :password, :superadmin
      )
    end

    def user_scope
      return User.all if user_is_editor?
      User.active.non_hidden
    end
end
