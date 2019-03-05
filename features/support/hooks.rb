# Evaluate if this is faster.
Before { DatabaseCleaner.strategy = :transaction }
Before "@javascript" do
  # "When set to true this will check each table for existing rows before truncating it."
  DatabaseCleaner.strategy = :truncation, { pre_count: true }
end

# Disable PaperTrail a lot.
Before { PaperTrail.enabled = false }
After  { PaperTrail.enabled = false }

# But allow features to enable it.
Before("@papertrail") { PaperTrail.enabled = true }
After("@papertrail")  { PaperTrail.enabled = false }

Around "@feed" do |_scenario, block|
  Feed.with_tracking { block.call }
end

# Some drivers remembers the window size between tests, so always restore.
Before("@responsive") { resize_window_to_device :desktop }
After("@responsive")  { resize_window_to_device :desktop }

Before "@no_travis" do
  if ENV["TRAVIS"]
    message = "scenario disabled on Travis CI"
    $stdout.puts message.red
    pending message
  end
end

Before "@chrome_only" do
  skip_this_scenario unless ENV['DRIVER'] == "chrome"
end

Before "@skip" do
  skip_this_scenario
end

# NOTE: Attempt to tackle memory leakage.
After do
  page.driver.reset!
end
