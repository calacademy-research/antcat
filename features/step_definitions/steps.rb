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
When("I click {string}") do |selector|
  find(selector).click
end

When("I press {string}") do |button|
  click_button button
end

When("I follow the first {string}") do |link|
  first(:link, link).click
end

When("I follow the second {string}") do |link|
  all(:link, link)[1].click
end

When("I follow {string}") do |link|
  click_link link
end

When(/^I follow "(.*?)" within (.*)$/) do |link, location|
  with_scope location do
    step %(I follow "#{link}")
  end
end

# Interact with form elements.
When("I fill in {string} with {string}") do |field, value|
  fill_in field, with: value
end

When(/^I fill in "(.*?)" with "(.*?)" within (.*)$/) do |field, value, within_element|
  with_scope within_element do
    fill_in field, with: value
  end
end

When("I select {string} from {string}") do |value, field|
  select value, from: field
end

When("I check {string}") do |field|
  check field
end

When("I uncheck {string}") do |field|
  uncheck field
end

When("I choose {string}") do |field|
  choose field
end

# "I should see / should contain".
Then("I should see {string}") do |text|
  expect(page).to have_content text, normalize_ws: true
end

Then("I should not see {string}") do |text|
  expect(page).to have_no_content text
end

Then(/^I should see "(.*?)" within (.*)$/) do |contents, location|
  with_scope location do
    step %(I should see "#{contents}")
  end
end

Then(/^I should not see "(.*?)" within (.*)$/) do |contents, location|
  with_scope location do
    step %(I should not see "#{contents}")
  end
end

Then("the {string} field should contain {string}") do |field, value|
  field = find_field field
  expect(field.value).to match value
end

Then("the {string} field within {string} should contain {string}") do |field, parent_element, value|
  within parent_element do
    field = find_field field
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
  begin
    evaluate_script "window.alert = function(msg) { return true; }"
    evaluate_script "window.confirm = function(msg) { return true; }"
    evaluate_script "window.prompt = function(msg) { return true; }"
  rescue Capybara::NotSupportedByDriverError # rubocop:disable Lint/HandleExceptions
  end
end

When("I will enter {string} in the prompt and confirm on the next step") do |string|
  begin
    evaluate_script "window.prompt = function(msg) { return '#{string}'; }"
  rescue Capybara::NotSupportedByDriverError => e
    warn e
  end
end
