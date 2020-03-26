# frozen_string_literal: true

InvisibleCaptcha.setup do |config|
  config.timestamp_enabled = true
  config.timestamp_threshold = 1 # Seconds.
end
