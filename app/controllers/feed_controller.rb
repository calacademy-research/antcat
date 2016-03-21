class FeedController < ApplicationController
  def show
    @activities = Feed::Activity.order(created_at: :desc)
      .paginate(page: params[:page])
  end
end
