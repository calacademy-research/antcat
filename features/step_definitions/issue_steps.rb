Given(/^there is an open issue "([^"]*)"$/) do |title|
  create :issue, :open, title: title
end

Given(/^there is a closed issue "([^"]*)"$/) do |title|
  create :issue, :closed, title: title
end

Then(/^I should see the (open|closed) issue "([^"]*)"$/) do |status, title|
  row = find "tr", text: title
  row.find "td", text: status.capitalize
end
