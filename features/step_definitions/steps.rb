# General steps, not specific to AntCat.

# Browser/navigation.
When(/^I go to (.+)$/) do |page_name|
  visit path_to(page_name)
end

Then(/^I should be on (.+)$/) do |page_name|
  current_path = URI.parse(current_url).path
  expect(current_path).to eq path_to(page_name)
end

Then("the page title should have {string} in it") do |title|
  expect(page.title).to have_content title, normalize_ws: true
end

When("I reload the page") do
  visit current_path
end

When("I wait") do
  sleep 1
end

Given("RESET SESSION") do
  Capybara.reset_sessions!
end

# Click/press/follow.
When(/^I click on (.*)$/) do |location|
  css_selector = selector_for location
  find(css_selector).click
end

When("I click css {string}") do |css_selector|
  find(css_selector).click
end

When("I press {string}") do |button_text|
  click_button button_text
end

When("I follow the first {string}") do |link_text|
  first(:link, link_text, exact: true).click
end

When("I follow the second {string}") do |link_text|
  all(:link, link_text, exact: true)[1].click
end

When("I follow {string}") do |link_text|
  click_link link_text
end

When(/^I follow "(.*?)" within (.*)$/) do |link_text, location|
  with_scope location do
    step %(I follow "#{link_text}")
  end
end

# Interact with form elements.
When("I fill in {string} with {string}") do |field_name, value|
  fill_in field_name, with: value
end

When(/^I fill in "(.*?)" with "(.*?)" within (.*)$/) do |field_name, value, location|
  with_scope location do
    fill_in field_name, with: value
  end
end

When("I select {string} from {string}") do |value, field_name|
  select value, from: field_name
end

When("I check {string}") do |field_name|
  check field_name
end

When("I uncheck {string}") do |field_name|
  uncheck field_name
end

When("I choose {string}") do |field_name|
  choose field_name
end

# "I should see / should contain".
Then("I should see {string}") do |content|
  expect(page).to have_content content, normalize_ws: true
end

Then("I should not see {string}") do |content|
  expect(page).to have_no_content content
end

Then(/^I should see "(.*?)" within (.*)$/) do |content, location|
  with_scope location do
    step %(I should see "#{content}")
  end
end

Then(/^I should not see "(.*?)" within (.*)$/) do |content, location|
  with_scope location do
    step %(I should not see "#{content}")
  end
end

Then("the {string} field should contain {string}") do |field_name, value|
  field = find_field field_name
  expect(field.value).to match value
end

Then("the {string} field within {string} should contain {string}") do |field_name, parent_css_selector, value|
  within parent_css_selector do
    field = find_field field_name
    expect(field.value).to match value
  end
end

# JavaScript alerts and prompts.
Then("I should see an alert {string}") do |message|
  accept_alert(message) do
    # No-op.
  end
end

And('I will confirm on the next step') do
  evaluate_script "window.alert = function(msg) { return true; }"
  evaluate_script "window.confirm = function(msg) { return true; }"
  evaluate_script "window.prompt = function(msg) { return true; }"
rescue Capybara::NotSupportedByDriverError
  nil
end

When("I will enter {string} in the prompt and confirm on the next step") do |string|
  evaluate_script "window.prompt = function(msg) { return '#{string}'; }"
rescue Capybara::NotSupportedByDriverError => e
  warn e
end
