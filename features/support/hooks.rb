Before "@responsive" do
  resize_window_to_device :desktop
end

After "@responsive" do
  resize_window_to_device :desktop
end

# TODO explain this
Before "@enable_taxon_browser_autohide" do
  $enable_taxon_browser_autohide = true
end

After "@enable_taxon_browser_autohide" do
  $enable_taxon_browser_autohide = false
end

# From http://makandracards.com/makandra/1709-single-step-and-
# slow-motion-for-cucumber-scenarios-using-javascript-selenium
# Use with `@javascript` and `DRIVER=selenium --format pretty` for the full experience.
Before '@slow_motion' do
  @slow_motion = true
end

After '@slow_motion' do
  @slow_motion = false
end

Transform /.*/ do |match|
  if @slow_motion
    sleep 1.5
  end
  match
end

AfterStep '@single_step' do
  print "Single Stepping. Hit enter to continue."
  STDIN.getc
end
