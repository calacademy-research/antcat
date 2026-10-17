# frozen_string_literal: true

module Users
  class PasswordsController < Devise::PasswordsController
    include RequestThrottle

    RESET_REQUESTS_PER_IP = 5
    RESET_REQUESTS_PER_EMAIL = 3
    RESET_REQUESTS_WITHIN = 1.hour
    TOO_MANY_REQUESTS_MESSAGE = "Too many password reset requests. Please wait a while and try again."

    # Each request can send an email, so it is throttled before Devise looks up the account.
    # The response does not say whether the email has an account (`config.paranoid`).
    def create
      if password_reset_throttled?
        redirect_to new_user_password_path, alert: TOO_MANY_REQUESTS_MESSAGE
        return
      end

      super
    end

    private

      def password_reset_throttled?
        request_throttled?(
          "password_reset",
          per_ip: RESET_REQUESTS_PER_IP, per_email: RESET_REQUESTS_PER_EMAIL,
          within: RESET_REQUESTS_WITHIN, email: params.dig(:user, :email)
        )
      end
  end
end
