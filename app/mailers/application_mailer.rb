# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  include Rails.application.routes.url_helpers

  UNSUBSCRIBE_VERIFIER_KEY = :unsubscribe_token

  append_view_path Rails.root.join('app/views/mailers')
  default from: "no-reply@antcat.org"
  layout 'mailer'

  private

    def ubsubscribe_token user
      Rails.application.message_verifier(UNSUBSCRIBE_VERIFIER_KEY).generate(user.id)
    end
end
