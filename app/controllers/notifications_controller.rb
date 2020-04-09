# frozen_string_literal: true

class NotificationsController < ApplicationController
  before_action :authenticate_user!
  after_action :mark_all_notifications_as_seen, only: :index

  def index
    if current_user.unseen_notifications.any?
      flash.now[:notice] = 'Marked all new notifications as seen.'
    end
    @notifications = current_user.notifications.most_recent_first.includes(:notifier, :attached).paginate(page: params[:page])
  end

  private

    def mark_all_notifications_as_seen
      current_user.mark_all_notifications_as_seen
    end
end
