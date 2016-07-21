class ActivitiesController < ApplicationController
  before_action :authenticate_superadmin, only: [:destroy]
  before_action :set_activity, only: [:destroy]

  def destroy
    @activity.destroy
    redirect_to feed_path, notice: "Activity was successfully deleted."
  end

  private
    def set_activity
      @activity = Feed::Activity.find(params[:id])
    end
end
