Given("there is an activity with the edit summary {string}") do |edit_summary|
  create :activity, :execute_script, edit_summary: edit_summary
end

Given("there is an automated activity with the edit summary {string}") do |edit_summary|
  create :activity, :execute_script, edit_summary: edit_summary, automated_edit: true
end

Then("I should see {int} item(s) in the feed") do |expected_count|
  feed_items_count = all("table.activities > tbody tr").size
  expect(feed_items_count).to eq expected_count.to_i
end

When("I hover the first activity item") do
  find("table.activities > tbody > tr:first-of-type .activity-link-wrapper").hover
end

Then("I should see the edit summary {string}") do |content|
  within "table.activities" do
    step %(I should see "#{content}")
  end
end

Given("there is a {string} journal activity by {string}") do |action, name|
  journal = create :journal
  user = User.find_by(name: name) || create(:user, name: name)
  create :activity, action: action.to_sym, trackable: journal, user: user
end

When("I click on Show more") do
  find("a", text: "Show more").click
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
