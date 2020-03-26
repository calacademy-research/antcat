# frozen_string_literal: true

module CucumberHelpers
  module WaitForJquery
    def wait_for_jquery
      Timeout.timeout(Capybara.default_max_wait_time) do
        loop do
          active = page.evaluate_script "jQuery.active"
          break if active == 0 # rubocop:disable Style/NumericPredicate
        end
      end
    end
  end
end

World CucumberHelpers::WaitForJquery
