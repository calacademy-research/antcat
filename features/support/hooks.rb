Before { DatabaseCleaner.strategy = :transaction }
Before "@javascript" do
  DatabaseCleaner.strategy = :deletion
end

# Disable PaperTrail a lot.
Before { PaperTrail.enabled = false }
After  { PaperTrail.enabled = false }

# But allow features to enable it.
Before("@papertrail") { PaperTrail.enabled = true }
After("@papertrail")  { PaperTrail.enabled = false }

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

Before "@skip" do
  skip_this_scenario
end

# NOTE: Attempt to tackle memory leakage.
After do
  page.driver.reset!
end
