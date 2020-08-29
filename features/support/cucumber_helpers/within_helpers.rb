# frozen_string_literal: true

module CucumberHelpers
  module WithinHelpers
    def with_scope locator, &block
      within(*selector_for(locator), &block)
    end
  end
end

World CucumberHelpers::WithinHelpers
