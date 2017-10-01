class UsersController < ApplicationController
  before_action :authenticate_editor, except: :index
  before_action :set_user, only: :show

  def index
    @users = User.order_by_name
  end

  def show
    @recent_user_activities = @user.activities.most_recent 5
    @recent_user_comments = @user.comments.most_recent 5
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
end
