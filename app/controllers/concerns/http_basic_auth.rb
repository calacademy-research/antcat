# frozen_string_literal: true

# Puts the whole site behind a browser password when `Settings.http_basic_auth.enabled` is on.
module HttpBasicAuth
  extend ActiveSupport::Concern

  included do
    http_basic_authenticate_with name: Settings.http_basic_auth.name,
      password: Settings.http_basic_auth.password, if: -> { Settings.http_basic_auth.enabled }
  end
end
