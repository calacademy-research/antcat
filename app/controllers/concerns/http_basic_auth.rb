# frozen_string_literal: true

module HttpBasicAuth
  extend ActiveSupport::Concern

  included do
    http_basic_authenticate_with name: Settings.http_basic_auth.name,
      password: Settings.http_basic_auth.password, if: -> { Settings.http_basic_auth.enabled }
  end
end
