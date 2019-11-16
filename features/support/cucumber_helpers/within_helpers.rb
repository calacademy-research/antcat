module CucumberHelpers
  module WithinHelpers
    def with_scope locator
      locator ? within(*selector_for(locator)) { yield } : yield
    end
  end
end

World CucumberHelpers::WithinHelpers
