When("I press the edit taxon link") do
  find("#edit-taxon-test-hook").click
end

# Without JavaScript, `I press "Save"` raises `Capybara::Ambiguous`.
When("I save the taxon form") do
  find("#save-taxon-form").click
end

Then(/^I (should|should not) see an Edit button$/) do |should_selector|
  if should_selector == "should not"
    expect(page).to have_no_css "a.btn-normal", text: "Edit"
  else
    expect(page).to have_css "a.btn-normal", text: "Edit"
  end
end

# fields section
### name field
When("I click the name field") do
  step 'I click "#name_field .display_button"'
end

When("I set the name to {string}") do |name|
  step %(I fill in "name_string" with "#{name}")
end

Then("I should still see the name field") do
  find '#name_field .edit'
end

Then("the name field should contain {string}") do |name|
  element = find '#name_string'
  expect(element.value).to eq name
end

# Try adding this (waiting finder) if the JS driver clicks on "OK" and
# then navigates to a different page before the JS has had time to execute.
# TODO probably include this in other steps so that it's always run.
Then("the name button should contain {string}") do |name|
  element = find '#name_field .display_button'
  expect(element.text).to eq name
end

# gender
When("I set the name gender to {string}") do |gender|
  step %(I select "#{gender}" from "taxon_name_attributes_gender")
end

Then(/^I should (not )?see the gender menu$/) do |should_not|
  if should_not
    expect(page).to have_no_css '#taxon_name_attributes_gender'
  else
    expect(page).to have_css '#taxon_name_attributes_gender'
  end
end

### parent field
When("I click the parent name field") do
  find('#parent_name_field .display_button').click
end

When("I set the parent name to {string}") do |name|
  step %(I fill in "name_string" with "#{name}")
end

Then("I should not see the parent name field") do
  expect(page).to_not have_css "#parent_row"
end

#### current valid taxon field
Then("the current valid taxon name should be {string}") do |name|
  taxon = Taxon.find_by(name_cache: name)
  element = find '#taxon_current_valid_taxon_id'
  expect(element.value).to eq taxon.id.to_s
end

When("I set the current valid taxon name to {string}") do |name|
  select2 name, from: 'taxon_current_valid_taxon_id'
end

# status
Then("the status should be {string}") do |status|
  expect(page).to have_css "select#taxon_status option[selected=selected][value=#{status}]"
end

When("I set the status to {string}") do |status|
  step %(I select "#{status}" from "taxon_status")
end

Then("the homonym replaced by name should be {string}") do |name|
  expected_value = if name == '(none)'
                     ''
                   else
                     Taxon.find_by(name_cache: name).id.to_s
                   end
  expect(find('#taxon_homonym_replaced_by_id').value).to eq expected_value
end

When("I set the homonym replaced by name to {string}") do |name|
  select2 name, from: 'taxon_homonym_replaced_by_id'
end

### authorship
When(/^I set the authorship to the first search results of "([^"]*)"$/) do |name|
  select2 name, from: 'taxon_protonym_attributes_authorship_attributes_reference_id'
end

Then(/^the authorship should contain the reference "([^"]*)"$/) do |keey|
  reference_id = find_reference_by_keey(keey).id
  selector = '#taxon_protonym_attributes_authorship_attributes_reference_id'
  expect(find(selector).value).to eq reference_id.to_s
end

When("I fill in the authorship notes with {string}") do |notes|
  step %(I fill in "taxon_protonym_attributes_authorship_attributes_notes_taxt" with "#{notes}")
end

### protonym name field
When("I click the protonym name field") do
  find('#protonym_name_field .display_button').click
end

Then("the protonym name field should contain {string}") do |name|
  element = find '#name_string'
  expect(element.value).to eq name
end

When("I set the protonym name to {string}") do |name|
  step %(I fill in "name_string" with "#{name}")
end

# type name field
When("I click the type name field") do
  find('#type_name_field .display_button').click
end

When("I set the type name to {string}") do |name|
  within '#type_name_field' do
    step %(I fill in "name_string" with "#{name}")
  end
end

Then("the type name field should contain {string}") do |name|
  element = find '#name_string'
  expect(element.value).to eq name
end

# convert species to subspecies
Then("the new species field should contain {string}") do |name|
  taxon = Taxon.find_by(name_cache: name)
  element = find '#new_species_id'
  expect(element.value).to eq taxon.id.to_s
end

When("I set the new species field to {string}") do |name|
  select2 name, from: 'new_species_id'
end

# Misc
Then("the taxon mouseover should contain {string}") do |text|
  element = find '.expandable-reference-key'
  expect(element['title']).to have_content text
end
