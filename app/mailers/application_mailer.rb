# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  # I *think* we need this, but it's not active because
  # it gets overridden by the env settings.
  default from: "no-reply@antcat.org"
  layout 'mailer'
end
