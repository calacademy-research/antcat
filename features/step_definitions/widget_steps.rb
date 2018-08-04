# Name field
When(/I click the allow_blank name field/) do
  step %(I click "#test_allow_blank_name_field .display_button")
end

When(/I click the new_or_homonym field/) do
  step %(I click "#test_new_or_homonym_name_field .display_button")
end

When(/the default_name_string field should contain "([^"]*)"/) do |name|
  element = find '#test_default_name_string_name_field #name_string'
  expect(element.value).to eq name
end

When(/I click the default_name_string field/) do
  step %(I click "#test_default_name_string_name_field .display_button")
end

When(/I click the test name field/) do
  step %(I click "#test_name_field .display_button")
end

# Misc
Given(/^there is a species name "([^"]*)"$/) do |name|
  find_or_create_name name
end
