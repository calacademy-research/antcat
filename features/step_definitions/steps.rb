# frozen_string_literal: true

# General steps, not specific to AntCat.

# Browser/navigation.
When(/^I go to (.+)$/) do |page_name|
  i_go_to page_name
end
def i_go_to page_name
  visit path_to(page_name)
end

Then(/^I should be on (.+)$/) do |page_name|
  i_should_be_on page_name
end
def i_should_be_on page_name
  current_path = URI.parse(current_url).path
  expect(current_path).to eq path_to(page_name)
end

Then("the page title be {string}") do |title|
  the_page_title_be title
end
def the_page_title_be title
  expect(page.title).to eq title
end

When("I reload the page") do
  i_reload_the_page
end
def i_reload_the_page
  visit current_path
end

# Click/press/follow.
When(/^I click on (.*)$/) do |location|
  i_click_on location
end
def i_click_on location
  css_selector = selector_for location
  find(css_selector).click
end

When("I click css {string}") do |css_selector|
  i_click_css css_selector
end
def i_click_css css_selector
  find(css_selector).click
end

When("I click css {string} with text {string}") do |css_selector, text|
  i_click_css_with_text css_selector, text
end
def i_click_css_with_text css_selector, text
  find(css_selector, text: text).click
end

When("I press {string}") do |button_text|
  i_press button_text
end
def i_press button_text
  click_button button_text
end

When("I follow the first {string}") do |link_text|
  i_follow_the_first link_text
end
def i_follow_the_first link_text
  first(:link, link_text, exact: true).click
end

When("I follow the second {string}") do |link_text|
  i_follow_the_second link_text
end
def i_follow_the_second link_text
  all(:link, link_text, exact: true)[1].click
end

When("I follow {string}") do |link_text|
  i_follow link_text
end
def i_follow link_text, within: nil
  if within
    with_scope within do
      i_follow link_text
    end
  else
    click_link link_text
  end
end

When(/^I follow "(.*?)" within (.*)$/) do |link_text, location|
  i_follow link_text, within: location
end

# Interact with form elements.
When("I fill in {string} with {string}") do |field_name, value|
  i_fill_in field_name, with: value
end
def i_fill_in field_name, with:, within: nil
  if within
    with_scope within do
      fill_in field_name, with: with
    end
  else
    fill_in field_name, with: with
  end
end

When(/^I fill in "(.*?)" with "(.*?)" within (.*)$/) do |field_name, value, location|
  i_fill_in field_name, with: value, within: location
end

When("I select {string} from {string}") do |value, field_name|
  i_select value, from: field_name
end
def i_select value, from:
  select value, from: from
end

When("I check {string}") do |field_name|
  i_check field_name
end
def i_check field_name
  check field_name
end

When("I uncheck {string}") do |field_name|
  i_uncheck field_name
end
def i_uncheck field_name
  uncheck field_name
end

Then("I should see {string} checked") do |field_name|
  i_should_see_checked field_name
end
def i_should_see_checked field_name
  expect(page.find(field_name).checked?).to eq true
end

Then("I should see {string} unchecked") do |field_name|
  i_should_see_unchecked field_name
end
def i_should_see_unchecked field_name
  expect(page.find(field_name).checked?).to eq false
end

# "I should see / should contain".
Then("I should see {string}") do |content|
  i_should_see content
end
def i_should_see content, within: nil
  if within
    with_scope within do
      expect(page).to have_content content, normalize_ws: true
    end
  else
    expect(page).to have_content content, normalize_ws: true
  end
end

Then("I should not see {string}") do |content|
  i_should_not_see content
end
def i_should_not_see content, within: nil
  if within
    with_scope within do
      i_should_not_see content
    end
  else
    expect(page).to have_no_content content
  end
end

Then(/^I should see "(.*?)" within (.*)$/) do |content, location|
  i_should_see content, within: location
end
# Merged with i_should_see.

Then(/^I should not see "(.*?)" within (.*)$/) do |content, location|
  with_scope location do
    step %(I should not see "#{content}")
  end
end
# Merged with i_should_not_see.

Then("the {string} field should contain {string}") do |field_name, value|
  the_field_should_contain field_name, value
end
def the_field_should_contain field_name, value
  field = find_field field_name
  expect(field.value).to match value
end

Then("the {string} field within {string} should contain {string}") do |field_name, parent_css_selector, value|
  the_field_within_should_contain field_name, parent_css_selector, value
end
def the_field_within_should_contain field_name, parent_css_selector, value
  within parent_css_selector do
    field = find_field field_name
    expect(field.value).to match value
  end
end

# JavaScript alerts and prompts.
Then("I should see an alert {string}") do |message|
  i_should_see_an_alert message
end
def i_should_see_an_alert message
  accept_alert(message) do
    # No-op.
  end
end

And('I will confirm on the next step') do
  i_will_confirm_on_the_next_step
end
def i_will_confirm_on_the_next_step
  evaluate_script "window.alert = function(msg) { return true; }"
  evaluate_script "window.confirm = function(msg) { return true; }"
  evaluate_script "window.prompt = function(msg) { return true; }"
rescue Capybara::NotSupportedByDriverError
  nil
end
