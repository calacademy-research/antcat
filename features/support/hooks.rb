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
