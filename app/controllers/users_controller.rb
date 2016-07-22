class UsersController < ApplicationController
  def index
    @users = User.order(:name).all
  end
end
