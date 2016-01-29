And 'I debug' do
  debugger
end

And 'I screenshot' do
  screenshot_and_save_page
end

And 'I pry' do
  binding.pry
end

And 'I pause' do
  print "Paused. Hit enter to continue."
  STDIN.getc
end
