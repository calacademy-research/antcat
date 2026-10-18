# frozen_string_literal: true

# Emails sent from the sign-up form (see `Users::RegistrationsController`). The form shows the same
# message whether or not the address already has an account; only the email says which it is.
class SignUpMailer < ApplicationMailer
  # The name typed in the form is not put in this email: anyone can type any name and any address,
  # so it would let them send their own text from antcat.org to anyone.
  def finish_sign_up email:, token:
    @url = complete_user_sign_up_url(token: token)
    @valid_for_hours = (Users::RegistrationsController::SIGN_UP_LINK_VALID_FOR / 1.hour).to_i

    mail to: email, subject: 'Finish signing up - antcat.org'
  end

  def already_registered user
    @user = user
    @login_url = new_user_session_url
    @forgot_password_url = new_user_password_url

    mail to: user.email, subject: 'You already have an account - antcat.org'
  end
end
