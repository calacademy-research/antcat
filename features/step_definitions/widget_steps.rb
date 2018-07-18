# Search
When(/^in the reference picker, I search for the authors? "([^"]*)"$/) do |authors|
  step %(I fill in the reference picker search box with "author:'#{authors}'")
  step %(I press "Go" by the reference picker search box)
end

# Reference field
When(/^I click the reference field$/) do
  step %(I click ".display_button")
end

# Reference popup
Then(/I should (not )?see the reference popup/) do |should_not|
  if should_not
    expect(find('.antcat_reference_popup', visible: false)).to_not be_visible
  else
    expect(find('.antcat_reference_popup', visible: true)).to be_visible
  end
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

# Name popup
Then(/^I should (not )?see the name popup edit interface$/) do |should_not|
  if should_not
    expect(find('#popup .controls', visible: false)).to_not be_visible
  else
    expect(find('#popup .controls', visible: true)).to be_visible
  end
end

Then(/^I should (not )?see the name popup$/) do |should_not|
  if should_not
    expect(find('.antcat_name_popup', visible: false)).to_not be_visible
  else
    expect(find('.antcat_name_popup', visible: true)).to be_visible
  end
end

# Results section
Then(/in the results section I should see the editable taxt for the name "([^"]*)"/) do |text|
  within "#results" do
    step %(I should see "#{TaxtIdTranslator.to_editor_nam_tag(Name.find_by_name(text))}")
  end
end

Then(/in the results section I should see the id for "([^"]*)"/) do |text|
  within "#results" do
    step %(I should see "#{Name.find_by_name(text).id}")
  end
end

Then(/in the results section I should see the id for the name "([^"]*)"/) do |text|
  within "#results" do
    step %(I should see "#{Name.find_by_name(text).id}")
  end
end

Then(/in the results section I should see the editable taxt for "([^"]*)"/) do |text|
  within "#results" do
    step %(I should see "#{TaxtIdTranslator.to_editor_tax_tag(Taxon.find_by_name(text))}")
  end
end

# Misc
Given(/^there is a species name "([^"]*)"$/) do |name|
  find_or_create_name name
end
