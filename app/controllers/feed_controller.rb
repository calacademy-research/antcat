class FeedController < ApplicationController
  def show
    @activities = Feed::Activity.order_by_date.paginate(page: params[:page])
  end
end
