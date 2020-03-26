# frozen_string_literal: true

module CucumberHelpers
  module WithinHelpers
    def with_scope locator
      within(*selector_for(locator)) { yield }
    end
  end
end

World CucumberHelpers::WithinHelpers
