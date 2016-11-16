When(/^I save my changes$/) do
  step 'I press "Save"'
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
  visible = should_not ? :false : :true
  selector = should_not ? :should_not : :should
  page.send selector, have_css('#taxon_name_attributes_gender', visible: visible)
end

# biogeographic region
Then(/^I should (not )?see the biogeographic region$/) do |should_not|
  selector = should_not ? :should_not : :should
  visible = should_not ? :false : :true
  page.send selector, have_css('#taxon_biogeographic_region', visible: visible)
end

# verbatim type locality
When(/I set the verbatim type locality to "([^"]*)"/) do |locality|
  step %{I fill in "taxon_verbatim_type_locality" with "San Pedro, CA"}
end

Then(/^I should (not )?see the verbatim type locality$/) do |should_not|
  selector = should_not ? :should_not : :should
  visible = should_not ? :false : :true

  page.send selector, have_css('#taxon_verbatim_type_locality', visible: visible)
end

Then(/^the verbatim type locality should be "([^"]*)"/) do |locality|
  step %{the "taxon_verbatim_type_locality" field should contain "#{locality}"}
end

# type specimen repository
When(/I set the type specimen repository to "([^"]*)"/) do |repository|
  step %{I fill in "taxon_type_specimen_repository" with "#{repository}"}
end

Then(/^I should (not )?see the type specimen repository$/) do |should_not|
  selector = should_not ? :should_not : :should
  visible = should_not ? :false : :true
  page.send selector, have_css('#taxon_type_specimen_repository', visible: visible)
end

Then(/^the type specimen repository should be "([^"]*)"/) do |repository|
  step %{the "taxon_type_specimen_repository" field should contain "#{repository}"}
end

# type specimen URL
When(/I set the type specimen URL to "([^"]*)"/) do |url|
  step %{I fill in "taxon_type_specimen_url" with "#{url}"}
end

Then(/^the type specimen URL should be "([^"]*)"/) do |url|
  step %{the "taxon_type_specimen_url" field should contain "#{url}"}
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
  visible = should_not ? :false : :true
  selector = should_not ? :should_not : :should
  find("#homonym_replaced_by_row", visible: visible).send(selector, be_visible)
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
