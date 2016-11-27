Given(/^there is an open issue "([^"]*)"$/) do |title|
  create :issue, title: title
end

Given(/^there is an? closed issue "([^"]*)"$/) do |title|
  create :closed_issue, title: title
end

Then(/^I should see the (open|closed) issue "([^"]*)"$/) do |status, title|
  row = find "tr", text: title
  row.find "td", text: status.capitalize
end
