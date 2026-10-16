# frozen_string_literal: true

module Users
  class SessionsController < Devise::SessionsController
    SIGN_IN_ATTEMPTS_PER_IP = 10
    SIGN_IN_ATTEMPTS_PER_EMAIL = 10
    SIGN_IN_ATTEMPTS_WITHIN = 3.minutes
    TOO_MANY_ATTEMPTS_MESSAGE = "Too many sign-in attempts. Please wait a few minutes and try again."

    # Checked at the top of `create`, before Devise authenticates, so a throttled attempt never
    # reaches the password check. Counters live in `Rails.cache` (shared by the Puma workers).
    def create
      if sign_in_throttled?
        redirect_to new_user_session_path, alert: TOO_MANY_ATTEMPTS_MESSAGE
        return
      end

      super
    end

    private

      def sign_in_throttled?
        email = params.dig(:user, :email).to_s.strip.downcase
        ip_over = over_limit?("sign_in:ip:#{client_ip}", SIGN_IN_ATTEMPTS_PER_IP)
        email_over = email.present? && over_limit?("sign_in:email:#{email}", SIGN_IN_ATTEMPTS_PER_EMAIL)
        ip_over || email_over
      end

      def over_limit? key, limit
        count = Rails.cache.increment(key, 1, expires_in: SIGN_IN_ATTEMPTS_WITHIN)
        count.to_i > limit
      end

      # Production is behind Cloudflare -> nginx -> Puma. nginx appends Cloudflare's edge IP to
      # X-Forwarded-For, so `request.remote_ip` is Cloudflare's address, not the visitor's.
      # Cloudflare sends the visitor's address in `CF-Connecting-IP`.
      def client_ip
        request.headers['CF-Connecting-IP'].presence || request.remote_ip
      end
  end
end
