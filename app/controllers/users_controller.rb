class UsersController < ApplicationController
  before_action :authenticate_superadmin, except: [:index, :show, :mentionables]
  before_action :set_user, only: [:show, :edit, :update]

  def index
    @users = User.order_by_name
  end

  def show
    @recent_user_activities = @user.activities.most_recent 5
    @recent_user_comments = @user.comments.most_recent 5
  end

  def new
    @user = User.new
  end

  def edit
  end

  def create
    @user = User.new user_params

    if @user.save
      redirect_to @user, notice: "Successfully added user."
    else
      render :new
    end
  end

  def update
    if @user.update_without_password user_params.except(:current_password)
      redirect_to @user, notice: "Successfully updated user."
    else
      render :edit
    end
  end

  def mentionables
    respond_to do |format|
      format.json do
        json = User.all.to_json root: false,
          only: [:id, :email, :name],
          methods: [:mentionable_search_key]
        render json: json
      end
    end
  end

  private

    def set_user
      @user = User.find params[:id]
    end

    def user_params
      params.require(:user).permit(:name, :email, :password, role_ids: [])
    end
end
