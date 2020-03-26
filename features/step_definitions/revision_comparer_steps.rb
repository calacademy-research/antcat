# frozen_string_literal: true

When("I follow the first linked history item") do
  first("a[href^='/taxon_history_items/']").click
end
