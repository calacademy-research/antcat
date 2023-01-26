# frozen_string_literal: true

Given("there is an activity with the edit summary {string}") do |edit_summary|
  there_is_an_activity_with_the_edit_summary edit_summary
end
def there_is_an_activity_with_the_edit_summary edit_summary
  create :activity, Activity::EXECUTE_SCRIPT, edit_summary: edit_summary
end

Given("there is an automated activity with the edit summary {string}") do |edit_summary|
  there_is_an_automated_activity_with_the_edit_summary edit_summary
end
def there_is_an_automated_activity_with_the_edit_summary edit_summary
  create :activity, Activity::EXECUTE_SCRIPT, :automated_edit, edit_summary: edit_summary
end

Then("I should see {int} item(s) in the activity feed") do |expected_count|
  i_should_see_number_of_items_in_the_activity_feed expected_count
end
def i_should_see_number_of_items_in_the_activity_feed expected_count
  feed_items_count = all("table.activities > tbody tr").size
  expect(feed_items_count).to eq expected_count.to_i
end

Then("I should see the edit summary {string}") do |content|
  i_should_see_the_edit_summary content
end
def i_should_see_the_edit_summary content
  within "table.activities" do
    i_should_see content
  end
end

Given("there is a {string} journal activity by {string}") do |event, name|
  there_is_a_journal_activity_by event, name
end
def there_is_a_journal_activity_by event, name
  journal = create :journal
  user = User.find_by(name: name) || create(:user, name: name)
  create :activity, event: event.to_sym, trackable: journal, user: user
end

Given("activities are paginated with {int} per page") do |per_page|
  activities_are_paginated_with_per_page per_page
end
def activities_are_paginated_with_per_page per_page
  Activity.per_page = per_page.to_i
end

Given("there are {int} activity items") do |number|
  there_are_number_of_activity_items number
end
def there_are_number_of_activity_items number
  number.to_i.times { create :activity }
end

Then(/^the query string should (not )?contain "([^"]*)"$/) do |should_not, contain|
  if should_not
    the_query_string_should_not_contain contain
  else
    the_query_string_should_contain contain
  end
end
def the_query_string_should_contain contain
  match = page.current_url[contain]
  expect(match).to be_truthy
end

def the_query_string_should_not_contain contain
  match = page.current_url[contain]
  expect(match).to eq nil
end
