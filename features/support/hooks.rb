# Disable PaperTrail a lot.
Before { PaperTrail.enabled = false }
After { PaperTrail.enabled = false }

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
