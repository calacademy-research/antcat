class ActivitiesController < ApplicationController
  before_filter :authenticate_superadmin, only: [:destroy]
  before_action :set_activity, only: [:destroy]

  # We need this at least temporarily when the feed is new,
  # so that the list isn't spammed with tons of activities
  # that should be bundled other activites (eg changing the
  # status of a subfamily should output "changed the status
  # of the subfamily Dorylinae and all (999) it children)"
  # and not 1000 different items.
  def destroy
    @activity.destroy
    redirect_to feed_path, notice: "Activity was successfully deleted."
  end

  private
    def set_activity
      @activity = Feed::Activity.find(params[:id])
    end
end
