# TODO replace with 'I press "Save"'.
When(/^I save my changes$/) do
  step 'I press "Save"'
end

# Without JavaScript, `I press "Save"` raises `Capybara::Ambiguous`.
When(/^I save the taxon form$/) do
  find("#save-taxon-form").click
end

Then(/^I (should|should not) see an Edit button$/) do |should_selector|
  if should_selector == "should not"
    expect(page).to have_no_css "a.btn-normal", text: "Edit"
  else
    expect(page).to have_css "a.btn-normal", text: "Edit"
  end
end

# section
When(/^I save the (\w+)(?: item)?$/) do |section|
  step %{I press the #{section} item "Save" button}
end

When(/^I cancel the (\w+) item's changes$/) do |section|
  step %{I press the #{section} item "Cancel" button}
end

When(/^I delete the (\w+) item$/) do |section|
  step %{I press the #{section} item "Delete" button}
end

# fields section
### name field
When(/^I click the name field$/) do
  step %{I click "#name_field .display_button"}
end

When(/^I set the name to "([^"]*)"$/) do |name|
  step %{I fill in "name_string" with "#{name}"}
end

Then(/^I should still see the name field$/) do
  element = find '#name_field .edit'
  expect(element).to be_visible
end

Then(/^the name field should contain "([^"]*)"$/) do |name|
  element = find '#name_string'
  expect(element.value).to eq name
end

# Try adding this (waiting finder) if the JS driver clicks on "OK" and
# then navigates to a different page before the JS has had time to execute.
# TODO probably include this in other steps so that it's always run.
Then(/^the name button should contain "([^"]*)"$/) do |name|
  element = find '#name_field .display_button'
  expect(element.text).to eq name
end

# Same as above for the convert to subspecies page.
Then(/^the target name button should contain "([^"]*)"$/) do |name|
  element = find '#new_species_id_field .display_button'
  expect(element.text).to eq name
end

# gender
When(/I set the name gender to "([^"]*)"/) do |gender|
  step %{I select "#{gender}" from "taxon_name_attributes_gender"}
end

Then(/^I should (not )?see the gender menu$/) do |should_not|
  if should_not
    expect(page).to have_no_css '#taxon_name_attributes_gender', visible: false
  else
    expect(page).to have_css '#taxon_name_attributes_gender', visible: true
  end
end

### parent field
When(/I click the parent name field/) do
  find('#parent_name_field .display_button').click
end

When(/^I set the parent name to "([^"]*)"$/) do |name|
  step %{I fill in "name_string" with "#{name}"}
end

Then(/^I should not see the parent name field/) do
  expect(page).to_not have_css "#parent_row"
end

#### current valid taxon field
Then(/the current valid taxon name should be "([^"]*)"$/) do |name|
  element = find '#current_valid_taxon_name_field div.display'
  expect(element.text).to eq name
end

When(/I click the current valid taxon name field/) do
  find('#current_valid_taxon_name_field .display_button').click
end

When(/^I set the current valid taxon name to "([^"]*)"$/) do |name|
  step %{I fill in "name_string" with "#{name}"}
end

# status
Then(/the status should be "([^"]*)"/) do |status|
  expect(page).to have_css "select#taxon_status option[selected=selected][value=#{status}]"
end

When(/I set the status to "([^"]*)"/) do |status|
  step %{I select "#{status}" from "taxon_status"}
end

### homonym replaced by field
Then(/^I should (not )?see the homonym replaced by field$/) do |should_not|
  if should_not
    expect(find("#homonym_replaced_by_row", visible: false)).to_not be_visible
  else
    expect(find("#homonym_replaced_by_row", visible: true)).to be_visible
  end
end

Then(/the homonym replaced by name should be "([^"]*)"$/) do |name|
  element = find '#homonym_replaced_by_name_field div.display'
  expect(element.text).to eq name
end

When(/I click the homonym replaced by name field/) do
  find('#homonym_replaced_by_name_field .display_button').click
end

When(/^I set the homonym replaced by name to "([^"]*)"$/) do |name|
  step %{I fill in "name_string" with "#{name}"}
end

### authorship
When(/^I click the authorship field$/) do
  step %{I click "#authorship_field .display_button"}
end

When(/^I fill in the authorship notes with "([^"]*)"$/) do |notes|
  step %{I fill in "taxon_protonym_attributes_authorship_attributes_notes_taxt" with "#{notes}"}
end

### protonym name field
When(/I click the protonym name field/) do
  find('#protonym_name_field .display_button').click
end

Then(/^the protonym name field should contain "([^"]*)"$/) do |name|
  element = find '#name_string'
  expect(element.value).to eq name
end

When(/^I set the protonym name to "([^"]*)"$/) do |name|
  step %{I fill in "name_string" with "#{name}"}
end

# type name field
When(/I click the type name field/) do
  find('#type_name_field .display_button').click
end

When(/^I set the type name to "([^"]*)"$/) do |name|
  within '#type_name_field' do
    step %{I fill in "name_string" with "#{name}"}
  end
end

Then(/^the type name field should contain "([^"]*)"$/) do |name|
  element = find '#name_string'
  expect(element.value).to eq name
end

# convert species to subspecies
When(/I click the new species field/) do
  find('#new_species_id_field .display_button').click
end

Then(/^the new species field should contain "([^"]*)"$/) do |name|
  element = find '#name_string'
  expect(element.value).to eq name
end

When(/^I set the new species field to "([^"]*)"$/) do |name|
  step %{I fill in "name_string" with "#{name}"}
end

# auto_generated
Then(/^the name "(.*?)" genus "(.*?)" should not be auto generated$/) do |species, genus|
  taxon = Taxon.find_by name_cache: "#{genus} #{species}"
  expect(taxon.auto_generated).to be_falsey
  expect(taxon.name.auto_generated).to be_falsey
end
