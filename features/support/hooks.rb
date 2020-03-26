# frozen_string_literal: true

Before { DatabaseCleaner.strategy = :transaction }
Before "@javascript" do
  DatabaseCleaner.strategy = :deletion
end

Around("@papertrail") do |_scenario, block|
  PaperTrail.enabled = true
  block.call
  PaperTrail.enabled = false
end

# Make sure PaperTrail is not enabled.
After("not @papertrail") do
  $stdout.puts "PaperTrail is enabled but should not be".red if PaperTrail.enabled?
end

if ENV['PRINT_FEATURE_NAME']
  Around do |scenario, block|
    $stdout.puts scenario.location.to_s.green
    block.call
  end
end

if ENV["TRAVIS"]
  Before "@skip_ci" do
    message = "scenario disabled on Travis CI"
    $stdout.puts message.red
    pending message
  end
end

Before "@skip" do
  skip_this_scenario
end

Before("@reset_driver") do
  page.driver.reset!
end
