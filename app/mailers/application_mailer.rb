# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  include Rails.application.routes.url_helpers

  append_view_path Rails.root.join('app/views/mailers')
  default from: "no-reply@antcat.org"
  layout 'mailer'
end
