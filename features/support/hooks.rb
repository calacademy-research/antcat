# We're having issues with production code enabling PaperTrail
# even when if it is globally disabled in the test env. Once enabled it
# stays enabled, which spills over into unrelated tests.
After do
  PaperTrail.enabled = false
end

# putting `require 'paper_trail/frameworks/cucumber'` inside support/env.rb and
#   config.after_initialize do
#     PaperTrail.enabled = false
#   end
# inside environments/test.rb is supposed to help, but it doesn't.
#
# Code for trying to find out what causes PaperTrail to become enabled.
# Uncomment if you enjoy colors and non-deterministic systems.
# Before do
#   if PaperTrail.enabled?
#     $stderr.puts "Before scenario: PaperTrail enabled".yellow
#   else
#     $stderr.puts "Before scenario: PaperTrail disabled".blue
#   end
# end
# AfterStep  do
#   if PaperTrail.enabled?
#     PaperTrail.enabled = false
#     $stderr.puts "After step: PaperTrail was enabled; disabled it".red
#   end
# end

Before "@papertrail" do
  PaperTrail.enabled = true
end

After "@papertrail" do
  PaperTrail.enabled = false
end

Around "@feed" do |scenario, block|
  Feed::Activity.with_tracking do
    block.call
  end
end

# Some drivers remembers the window size between tests, so always restore.
Before "@responsive" do
  resize_window_to_device :desktop
end

After "@responsive" do
  resize_window_to_device :desktop
end

Before "@no_travis" do
  if ENV["TRAVIS"]
    message = "scenario disabled on Travis CI"
    $stdout.puts message.red
    pending message
  end
end
