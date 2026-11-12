# frozen_string_literal: true

require 'rails_helper'

# Specs switch a setting on for their examples (`Settings.api_keys.enabled = true`,
# `Settings.http_basic_auth.enabled = true`, ...) and do not set it back themselves: the settings files are
# read again after every example (`config.after { Config.reload! }` in spec/support/rspec.rb), so a
# changed setting cannot reach a later example, whatever the order. These two examples run in the
# order written to show it.
describe "Settings changed in an example", order: :defined do # rubocop:disable RSpec/DescribeClass
  it "are changed for that example" do
    Settings.api_keys.enabled = true

    expect(ApiAccess.enabled?).to be true
  end

  it "have the files' values again in the next example" do
    expect(Settings.api_keys.enabled).to be false
    expect(ApiAccess.enabled?).to be false
  end

  it "are reloaded by a hook that runs after every example" do
    expect(Rails.root.join("spec/support/rspec.rb").read).to match(/config\.after do\n\s+Config\.reload!\n\s+end/)
  end
end
