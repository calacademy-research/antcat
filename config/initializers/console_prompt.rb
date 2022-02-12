# frozen_string_literal: true

require 'irb'

# To get rid of `irb: warn: can't alias context from irb_context` in case RSpec in loaded
# with default config (where `expose_dsl_globally = true`), see https://stackoverflow.com/a/24973151
RSpec.configure { |config| config.expose_dsl_globally = false } if defined?(RSpec)

IRB.conf[:PROMPT] ||= {}
IRB.conf[:PROMPT][:RAILS_APP] = {
  PROMPT_I: "antcat (#{Rails.env})> ",
  PROMPT_N: nil,
  PROMPT_S: nil,
  PROMPT_C: nil,
  RETURN: "=> %s\n"
}

IRB.conf[:PROMPT_MODE] = :RAILS_APP
