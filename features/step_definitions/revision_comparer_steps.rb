# frozen_string_literal: true

When("I follow the first linked history item") do
  first("a[href^='/history_items/']").click
end
