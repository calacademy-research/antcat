Given(/^there is an open task "([^"]*)"$/) do |title|
  create :task, title: title
end

Given(/^there is an? closed task "([^"]*)"$/) do |title|
  create :closed_task, title: title
end

Then(/^I should see the (open|closed|completed) task "([^"]*)"$/) do |status, title|
  row = find "tr", text: title
  row.find "td", text: status.capitalize
end
