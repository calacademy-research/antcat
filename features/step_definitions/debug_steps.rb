And(/^(?:I debug|DEBUG)$/) do
  debugger
end

And(/^(?:I screenshot|SCREEN|SHOT)$/) do
  screenshot_and_save_page
end

And(/^(?:I pry|PRY)/) do
  binding.pry
end

And(/^(?:I pause|PAUSE)$/) do
  print "Paused. Hit enter to continue."
  STDIN.getc
end

And(/^(?:I wait|WAIT|)$/) do
  sleep 1
end

Given(/^PENDING/) do
  pending
end
