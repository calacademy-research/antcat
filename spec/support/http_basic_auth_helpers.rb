# frozen_string_literal: true

module HttpBasicAuthHelpers
  def with_valid_http_basic_auth_credentials!
    name = Settings.http_basic_auth.name
    password = Settings.http_basic_auth.password

    auth = ActionController::HttpAuthentication::Basic.encode_credentials(name, password)
    request.env['HTTP_AUTHORIZATION'] = auth
  end
end
