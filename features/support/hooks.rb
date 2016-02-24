Before "@responsive" do
  resize_window_to_device :desktop
end

After "@responsive" do
  resize_window_to_device :desktop
end

# Temporary work-around.
# Basically:
#   In dev/prod: autohide taxon browser and [TODO] close all except the last panel
#   In test: don't autohide, and open all panels (performance/test reasons)
#   In @taxon_browser tests: behave as in prod/dev
# Added in f3f10710011ad3b3ccdbc3059ffa000f8be8fbd3.
Before "@taxon_browser" do
  $taxon_browser_test_hack = true
end

After "@taxon_browser" do
  $taxon_browser_test_hack = false
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
