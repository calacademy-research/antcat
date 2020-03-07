Before { DatabaseCleaner.strategy = :transaction }
Before "@javascript" do
  DatabaseCleaner.strategy = :deletion
end

Around("@papertrail") do |_scenario, block|
  PaperTrail.enabled = true
  block.call
  PaperTrail.enabled = false
end

# Some drivers remember window size between tests, so always start and end with desktop.
Before("@responsive") { resize_window_to_device :desktop }
After("@responsive")  { resize_window_to_device :desktop }

if ENV['PRINT_FEATURE_NAME']
  Around do |scenario, block|
    $stdout.puts scenario.location.to_s.green
    block.call
  end
end

Before "@skip_ci" do
  if ENV["TRAVIS"]
    message = "scenario disabled on Travis CI"
    $stdout.puts message.red
    pending message
  end
end

Before "@skip" do
  skip_this_scenario
end

# NOTE: Attempt to tackle memory leakage.
After do
  page.driver.reset!
end
