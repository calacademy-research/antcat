if ENV["COVERAGE"]
  require 'simplecov'

  SimpleCov.command_name "rspec"
  SimpleCov.start
end

# Uncomment for bonus stuff.
# DevMonkeyPatches.enable!
