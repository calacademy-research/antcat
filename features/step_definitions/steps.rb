require File.expand_path(File.join(File.dirname(__FILE__), "..", "support", "paths"))
require File.expand_path(File.join(File.dirname(__FILE__), "..", "support", "selectors"))

module WithinHelpers
  def with_scope locator
    locator ? within(*selector_for(locator)) { yield } : yield
  end
end
World WithinHelpers

# Go to / be on
When(/^(?:|I )go to (.+)$/) do |page_name|
  visit path_to(page_name)
end

Then(/^(?:|I )should be on (.+)$/) do |page_name|
  current_path = URI.parse(current_url).path
  expect(current_path).to eq path_to(page_name)
end

# Click/press
When(/^(?:|I )press "([^"]*)"$/) do |button|
  click_button button
end

When(/^(?:|I )press the first "([^"]*)"$/) do |button|
  first(:button, button).click
end

When(/^(?:|I )follow the first "([^"]*)"$/) do |link|
  first(:link, link).click
end

When(/^(?:|I )follow the second "([^"]*)"$/) do |link|
  all(:link, link)[1].click
end

When(/^(?:|I )follow "([^"]*)"$/) do |link|
  click_link link
end

When(/^I click "([^"]*)"$/) do |selector|
  find(selector).click
end

When(/I follow "(.*?)" (?:with)?in (.*)$/) do |link, location|
  with_scope location do
    step %{I follow "#{link}"}
  end
end

When(/I press "(.*?)" (?:with)?in (.*)$/) do |button, location|
  with_scope location do
    step %{I press "#{button}"}
  end
end

# Interact with form elements
When(/^(?:|I )fill in "([^"]*)" with "([^"]*)"$/) do |field, value|
  fill_in field, with: value
end

When(/^(?:|I )select "([^"]*)" from "([^"]*)"$/) do |value, field|
  select value, from: field
end

When(/^(?:|I )check "([^"]*)"$/) do |field|
  check field
end

When(/^(?:|I )uncheck "([^"]*)"$/) do |field|
  uncheck field
end

When(/^(?:|I )choose "([^"]*)"$/) do |field|
  choose field
end

# "I should see/contain/selected ..."
Then(/^(?:|I )should see "([^"]*)"$/) do |text|
  expect(page).to have_content text
end

Then(/^(?:|I )should not see "([^"]*)"$/) do |text|
  expect(page).to have_no_content text
end

Then(/^the "([^"]*)" field(?: within (.*))? should contain "([^"]*)"$/) do |field, parent, value|
  with_scope(parent) do
    field = find_field field
    field_value = (field.tag_name == 'textarea') ? field.text : field.value
    expect(field_value).to match /#{value}/
  end
end

Then(/^I should see a link "([^"]*)"$/) do |link|
  expect(page).to have_css 'a', text: link
end

Then(/I should (not )?see "(.*?)" (?:with)?in (.*)$/) do |do_not, contents, location|
  with_scope location do
    step %{I should #{do_not}see "#{contents}"}
  end
end

Then(/^I should see "([^"]*)" selected in "([^"]*)"$/) do |value, select|
  expect(page).to have_select select, selected: value
end

Then(/^"([^"]+)" should be selected(?: in (.*))?$/) do |word, location|
  with_scope location || 'the page' do
    expect(page).to have_css ".selected", text: word
  end
end

Then(/^"([^"]*)" should be checked$/) do |checkbox_id|
  checkbox = find "##{checkbox_id}"
  expect(checkbox).to be_checked
end

# Misc
And('I will confirm on the next step') do
  begin
    evaluate_script "window.alert = function(msg) { return true; }"
    evaluate_script "window.confirm = function(msg) { return true; }"
  rescue Capybara::NotSupportedByDriverError
  end
end

When(/^I wait$/) do
  sleep 1
end

Given(/^RESET SESSION$/) do
  Capybara.reset_sessions!
end

Then(/^the page title should have "([^"]*)" in it$/) do |title|
  expect(page.title).to have_content title
end

Given(/that URL "([^"]*)" exists/) do |link|
  stub_request :any, link
end

When(/^I reload the page$/) do
  visit current_path
end

Then("I should not see any error messages") do
  expect(page).to_not have_css '.error_messages li'
end

When(/^I follow "([^"]*)" inside the breadcrumb$/) do |link|
  within "#breadcrumbs" do
    step %{I follow "#{link}"}
  end
end

Then(/I should see "([^"]*)" italicized/) do |italicized_text|
  expect(page).to have_css 'i', text: italicized_text
end

# HACK to prevent the driver from navigating away
# from the page before completing the request.
And(/^I wait for the "success" message$/) do
  step 'I should see "uccess"' # "[Ss]uccess(fully)?"
end
