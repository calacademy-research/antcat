# frozen_string_literal: true

Given("I have an(other) unseen notification") do
  create :notification, user: User.find_by!(name: "Archibald")
end

Then("I should see {int} notification(s)") do |expected_count|
  all "table.notifications > tbody tr", count: expected_count.to_i
end

Then("I should see {int} unread notification(s)") do |expected_count|
  all "table.notifications .antcat_icon.unseen", count: expected_count.to_i
end

Given("there is an open issue {string} created by {string}") do |title, name|
  create :issue, title: title, user: User.find_by!(name: name)
end

When(/^I write a new comment <at Batiatus's id> "([^"]*)"$/) do |content|
  user = User.find_by!(name: "Batiatus")
  first("#comment_body").set "@user#{user.id} #{content}"
end
