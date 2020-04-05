# frozen_string_literal: true

class NotificationsController < ApplicationController
  before_action :authenticate_user!
  after_action :mark_unseen_as_seen, only: :index

  def index
    if current_user.unseen_notifications.any?
      flash.now[:notice] = 'Mark new notifications as seen.'
    end
    @notifications = current_user.notifications.order(id: :desc).includes(:notifier, :attached).paginate(page: params[:page])
  end

  private

    def mark_unseen_as_seen
      current_user.mark_unseen_notifications_as_seen
    end
end
