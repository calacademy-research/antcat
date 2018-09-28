# Reference selector.
# HACK
Given("the reference selector returns {int} results per page") do |items_per_page|
  allow_any_instance_of(Autocomplete::AutocompleteReferences).
    to receive(:default_search_options).
    and_return(reference_type: :nomissing, items_per_page: items_per_page)
end

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
  create :genus_name, name: name
end
