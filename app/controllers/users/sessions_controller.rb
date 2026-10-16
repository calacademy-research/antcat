# frozen_string_literal: true

module Users
  class SessionsController < Devise::SessionsController
    SIGN_IN_ATTEMPTS_PER_IP = 10
    SIGN_IN_ATTEMPTS_PER_EMAIL = 10
    SIGN_IN_ATTEMPTS_WITHIN = 3.minutes
    TOO_MANY_ATTEMPTS_MESSAGE = "Too many sign-in attempts. Please wait a few minutes and try again."

    # NOTE: Counters are kept in the controller cache store (`Rails.cache` unless configured otherwise).
    rate_limit to: SIGN_IN_ATTEMPTS_PER_IP, within: SIGN_IN_ATTEMPTS_WITHIN, only: :create, name: "ip",
      by: -> { client_ip },
      with: -> { redirect_to new_user_session_path, alert: TOO_MANY_ATTEMPTS_MESSAGE }
    rate_limit to: SIGN_IN_ATTEMPTS_PER_EMAIL, within: SIGN_IN_ATTEMPTS_WITHIN, only: :create, name: "email",
      by: -> { params.dig(:user, :email).to_s.strip.downcase },
      with: -> { redirect_to new_user_session_path, alert: TOO_MANY_ATTEMPTS_MESSAGE }

    private

      # Production is behind Cloudflare -> nginx -> Puma. nginx appends Cloudflare's edge IP to
      # X-Forwarded-For, so `request.remote_ip` is Cloudflare's address, not the visitor's.
      # Cloudflare sends the visitor's address in `CF-Connecting-IP`.
      def client_ip
        request.headers['CF-Connecting-IP'].presence || request.remote_ip
      end
  end
end
