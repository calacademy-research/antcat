# frozen_string_literal: true

module Activities
  class UnconfirmedsController < ApplicationController
    before_action :authenticate_user!

    def show
      @activities = Activity.unconfirmed.includes(:user).paginate(page: params[:page])
    end
  end
end
