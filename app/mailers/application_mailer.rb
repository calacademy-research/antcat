# frozen_string_literal: true

# The base of the app's mailers: sender "AntCat <antcat@antcat.org>", the mail layout and the URL helpers.
class ApplicationMailer < ActionMailer::Base
  include Rails.application.routes.url_helpers

  append_view_path Rails.root.join('app/views/mailers')
  default from: "AntCat <antcat@antcat.org>"
  layout 'mailer'
end
