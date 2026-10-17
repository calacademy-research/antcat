# frozen_string_literal: true

module Users
  class SessionsController < Devise::SessionsController
    include RequestThrottle

    SIGN_IN_ATTEMPTS_PER_IP = 10
    SIGN_IN_ATTEMPTS_PER_EMAIL = 10
    SIGN_IN_ATTEMPTS_WITHIN = 3.minutes
    TOO_MANY_ATTEMPTS_MESSAGE = "Too many sign-in attempts. Please wait a few minutes and try again."

    # Checked at the top of `create`, before Devise authenticates, so a throttled attempt never
    # reaches the password check. See `RequestThrottle`.
    def create
      if sign_in_throttled?
        redirect_to new_user_session_path, alert: TOO_MANY_ATTEMPTS_MESSAGE
        return
      end

      super
    end

    private

      def sign_in_throttled?
        request_throttled?(
          "sign_in",
          per_ip: SIGN_IN_ATTEMPTS_PER_IP, per_email: SIGN_IN_ATTEMPTS_PER_EMAIL,
          within: SIGN_IN_ATTEMPTS_WITHIN, email: params.dig(:user, :email)
        )
      end
  end
end
