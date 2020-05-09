# frozen_string_literal: true

class VerifyRecaptchaV3
  include Service

  SECRET_KEY = Settings.recaptcha.v3.secret_key

  attr_private_initialize :token, :recaptcha_action

  def call
    recaptcha_valid?
  end

  private

    def recaptcha_valid?
      response = Net::HTTP.get_response(uri)
      json = JSON.parse(response.body)
      json['success'] && json['score'] > Settings.recaptcha.v3.minimum_score && json['action'] == recaptcha_action
    end

    def uri
      URI.parse("https://www.google.com/recaptcha/api/siteverify?secret=#{SECRET_KEY}&response=#{token}")
    end
end
