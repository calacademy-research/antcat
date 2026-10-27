# frozen_string_literal: true

class VerifyRecaptchaV3
  include Service

  SECRET_KEY = Settings.recaptcha.v3.secret_key
  VERIFY_URL = "https://www.google.com/recaptcha/api/siteverify"
  TIMEOUT_SECONDS = 5

  attr_private_initialize :token, :recaptcha_action

  def call
    recaptcha_valid?
  end

  private

    # The token comes from the client: it is sent form-encoded (never put into the URL), together with the secret.
    # An error or unexpected answer from Google counts as not valid.
    def recaptcha_valid?
      json = JSON.parse(verify_response.body)
      json['success'] == true && json['score'].to_f > Settings.recaptcha.v3.minimum_score && json['action'] == recaptcha_action
    rescue JSON::ParserError, Net::OpenTimeout, Net::ReadTimeout, SocketError, SystemCallError, OpenSSL::SSL::SSLError
      false
    end

    def verify_response
      uri = URI(VERIFY_URL)

      Net::HTTP.start(uri.host, uri.port, use_ssl: true, open_timeout: TIMEOUT_SECONDS, read_timeout: TIMEOUT_SECONDS) do |http|
        request = Net::HTTP::Post.new(uri)
        request.set_form_data(secret: SECRET_KEY, response: token.to_s)
        http.request(request)
      end
    end
end
