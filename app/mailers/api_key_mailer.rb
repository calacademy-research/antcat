# frozen_string_literal: true

# Emails for free API keys (see `ApiKeysController`). The key itself is never put in an email.
class ApiKeyMailer < ApplicationMailer
  # To the address typed in the form. Only the link: the name and project typed in the form are not
  # put in it, so the form cannot be used to send someone else's text from antcat.org.
  def confirm_email api_key, token
    @url = confirm_api_key_url(token: token)
    @valid_for_hours = (ApiKey::CONFIRMATION_VALID_FOR / 1.hour).to_i

    mail to: api_key.email, subject: 'Your AntCat API key: confirm your email address'
  end

  # A copy of each registration (when the key is issued) for the AntCat lead, with a link to the admin page.
  def registration_copy api_key
    @api_key = api_key
    @admin_url = edit_panel_api_key_url(api_key)

    mail to: Settings.api_keys.registration_copy_to, subject: "New AntCat API key: #{api_key.name.squish.truncate(60)}"
  end
end
