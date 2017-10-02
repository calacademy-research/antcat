def wait_for_jquery
  Timeout.timeout(Capybara.default_max_wait_time) do
    loop do
      active = page.evaluate_script "jQuery.active"
      break if active == 0
    end
  end
end
