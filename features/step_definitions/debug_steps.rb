# frozen_string_literal: true

And("PAUSE") do
  print "Paused. Hit enter to continue."
  STDIN.getc
end

And("PRY") do
  binding.pry # rubocop:disable Lint/Debugger
end

And("SHOT") do
  screenshot_and_save_page
end

And("RESET_SESSION") do
  Capybara.reset_sessions!
end

And("WAIT") do
  sleep 1
end

And("WAIT_FOR_JQUERY") do
  Timeout.timeout(Capybara.default_max_wait_time) do
    loop do
      active = page.evaluate_script "jQuery.active"
      break if active == 0 # rubocop:disable Style/NumericPredicate
    end
  end
end
