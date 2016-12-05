When(/^I follow the first linked history item$/) do
  first("a[href^='/taxon_history_items/']").click
end

When(/^I follow the first linked reference section$/) do
  first("a[href^='/reference_sections/']").click
end
