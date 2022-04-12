# frozen_string_literal: true

Given("there is an activity with the edit summary {string}") do |edit_summary|
  create :activity, Activity::EXECUTE_SCRIPT, edit_summary: edit_summary
end

Given("there is an automated activity with the edit summary {string}") do |edit_summary|
  create :activity, Activity::EXECUTE_SCRIPT, :automated_edit, edit_summary: edit_summary
end

Then("I should see {int} item(s) in the activity feed") do |expected_count|
  feed_items_count = all("table.activities > tbody tr").size
  expect(feed_items_count).to eq expected_count.to_i
end

Then("I should see the edit summary {string}") do |content|
  within "table.activities" do
    step %(I should see "#{content}")
  end
end

Given("there is a {string} journal activity by {string}") do |event, name|
  journal = create :journal
  user = User.find_by(name: name) || create(:user, name: name)
  create :activity, event: event.to_sym, trackable: journal, user: user
end

Given("activities are paginated with {int} per page") do |per_page|
  Activity.per_page = per_page.to_i
end

Given("there are {int} activity items") do |number|
  number.to_i.times { create :activity }
end

Then(/^the query string should (not )?contain "([^"]*)"$/) do |should_not, contain|
  match = page.current_url[contain]
  if should_not
    expect(match).to eq nil
  else
    expect(match).to be_truthy
  end
end
