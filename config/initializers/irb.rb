# frozen_string_literal: true

require 'irb'

# To get rid of `irb: warn: can't alias context from irb_context` in case RSpec in loaded
# with default config (where `expose_dsl_globally = true`), see https://stackoverflow.com/a/24973151
RSpec.configure { |config| config.expose_dsl_globally = false } if defined?(RSpec)

IRB.conf[:USE_MULTILINE] = false

ENV_COLORS = {
  'production' => :light_blue,
  'staging' => :light_magenta,
  'development' => :light_green,
  'test' => :light_yellow
}
env_color = ENV_COLORS.fetch(Rails.env)
colorized_env = Rails.env.to_s.on_black.public_send(env_color)

IRB.conf[:PROMPT] ||= {}
IRB.conf[:PROMPT][:RAILS_APP] = {
  PROMPT_I: "antcat (#{colorized_env})> ",
  PROMPT_N: nil,
  PROMPT_S: nil,
  PROMPT_C: nil,
  RETURN: "=> %s\n"
}

IRB.conf[:PROMPT_MODE] = :RAILS_APP
