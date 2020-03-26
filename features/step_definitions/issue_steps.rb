# frozen_string_literal: true

Given("there is an open issue {string}") do |title|
  create :issue, :open, title: title, adder: User.first
end

Then(/^I should see the (open|closed) issue "([^"]*)"$/) do |status, title|
  row = find :css, "tr.#{status.downcase}"
  row.find "td", text: title
end
