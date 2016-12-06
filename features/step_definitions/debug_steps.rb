And(/^DEBUG$/) do
  debugger
end

And(/^SHOT$/) do
  screenshot_and_save_page
end

And(/^PRY$/) do
  binding.pry
end

And(/^PAUSE$/) do
  print "Paused. Hit enter to continue."
  STDIN.getc
end

And(/^WAIT$/) do
  sleep 1
end

Given(/^PENDING/) do
  pending
end
