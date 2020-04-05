# frozen_string_literal: true

class UnsubscribesController < ApplicationController
  rescue_from ActiveSupport::MessageVerifier::InvalidSignature do
    redirect_to root_path, alert: 'Token invalid. Unable to unsubscribe. Email us?'
  end

  def show
    @user = find_user params[:token]
  end

  def create
    user = find_user params[:token]

    if user.update(enable_email_notifications: false)
      redirect_to root_path, notice: "You have been unsubscribed from emails notifications"
    else
      render :unsubscribe, alert: "Something went wrong. Please email us."
    end
  end

  private

    def find_user token
      user_id = verified_user_id(token)
      User.find_by(id: user_id)
    end

    def verified_user_id token
      Rails.application.message_verifier(ApplicationMailer::UNSUBSCRIBE_VERIFIER_KEY).verify(token)
    end
end
