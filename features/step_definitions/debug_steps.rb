And("SHOT") do
  screenshot_and_save_page
end

And("PRY") do
  binding.pry # rubocop:disable Lint/Debugger
end

And("PAUSE") do
  print "Paused. Hit enter to continue."
  STDIN.getc
end

And("WAIT") do
  sleep 1
end

And("WAIT_FOR_JQUERY") do
  wait_for_jquery
end

And("MONKEY") do
  DevMonkeyPatches.enable!
end

Given(/^PENDING/) do
  pending
end
