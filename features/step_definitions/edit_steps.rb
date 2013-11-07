# coding: UTF-8
When /^I save my changes$/ do
  step 'I press "Save"'
end

# section
When /^I save the (\w+)(?: item)?$/ do |section|
  step %{I press the #{section} item "Save" button}
end
When /^I cancel the (\w+) item's changes$/ do |section|
  step %{I press the #{section} item "Cancel" button}
end
When /^I delete the (\w+) item$/ do |section|
  step %{I press the #{section} item "Delete" button}
end

# fields section

### name field
And /^I click the name field$/ do
  step %{I click "#name_field .display_button"}
end
When /^I set the name to "([^"]*)"$/ do |name|
  step %{I fill in "name_string" with "#{name}"}
end
Then /^I should still see the name field$/ do
  page.find('#name_field .edit').should be_visible
end
When /^the name field should contain "([^"]*)"$/ do |name|
  find('#name_string').value.should == name
end

# gender
Then /I set the name gender to "([^"]*)"/ do |gender|
  step %{I select "#{gender}" from "taxon_name_attributes_gender"}
end
Then /^I should (not )?see the gender menu$/ do |should_not|
  selector = should_not ? :should_not : :should
  page.send selector, have_css('#taxon_name_attributes_gender')
end

# verbatim type locality
Then /I set the verbatim type locality to "([^"]*)"/ do |locality|
  step %{I fill in "taxon_verbatim_type_locality" with "San Pedro, CA"}
end
Then /^I should (not )?see the verbatim type locality$/ do |should_not|
  selector = should_not ? :should_not : :should
  page.send selector, have_css('#taxon_verbatim_type_locality')
end
Then /^the verbatim type locality should be "([^"]*)"/ do |locality|
  step %{the "taxon_verbatim_type_locality" field should contain "#{locality}"}
end

### parent field
When /I click the parent name field/ do
  find('#parent_name_field .display_button').click
end
When /^I set the parent name to "([^"]*)"$/ do |name|
  step %{I fill in "name_string" with "#{name}"}
end
Then /^I should not see the parent name field/ do
  page.should_not have_css "#parent_row"
end

# status
Then /the status should be "([^"]*)"/ do |status|
  page.should have_css "select#taxon_status option[selected=selected][value=#{status}]"
end
Then /I set the status to "([^"]*)"/ do |status|
  step %{I select "#{status}" from "taxon_status"}
end

### homonym replaced by field
Then /^I should (not )?see the homonym replaced by field$/ do |should_not|
  selector = should_not ? :should_not : :should
  find("#homonym_replaced_by_row").send(selector, be_visible)
end
When /the homonym replaced by name should be "([^"]*)"$/ do |name|
  page.find('#homonym_replaced_by_name_field div.display').text.should == name
end
When /I click the homonym replaced by name field/ do
  find('#homonym_replaced_by_name_field .display_button').click
end
When /^I set the homonym replaced by name to "([^"]*)"$/ do |name|
  step %{I fill in "name_string" with "#{name}"}
end

### authorship
And /^I click the authorship field$/ do
  step %{I click "#authorship_field .display_button"}
end
When /^I fill in the authorship notes with "([^"]*)"$/ do |notes|
  step %{I fill in "taxon_protonym_attributes_authorship_attributes_notes_taxt" with "#{notes}"}
end

### protonym name field
When /I click the protonym name field/ do
  find('#protonym_name_field .display_button').click
end
When /^the protonym name field should contain "([^"]*)"$/ do |name|
  find('#name_string').value.should == name
end
When /^I set the protonym name to "([^"]*)"$/ do |name|
  step %{I fill in "name_string" with "#{name}"}
end

# type name field
When /I click the type name field/ do
  find('#type_name_field .display_button').click
end
When /^I set the type name to "([^"]*)"$/ do |name|
  within '#type_name_field' do
    step %{I fill in "name_string" with "#{name}"}
  end
end
When /^the type name field should contain "([^"]*)"$/ do |name|
  find('#name_string').value.should == name
end

# convert species to subspecies
When /I click the new species field/ do
  find('#new_species_id_field .display_button').click
end
When /^the new species field should contain "([^"]*)"$/ do |name|
  find('#name_string').value.should == name
end
When /^I set the new species field to "([^"]*)"$/ do |name|
  step %{I fill in "name_string" with "#{name}"}
end

# history section
When /^I press the history item "([^"]*)" button$/ do |button|
  within '.history_items .history_item' do
    step %{I press "#{button}"}
  end
end
When /^I click the history item$/ do
  find('.history_items .history_item div.display').click
end
Then /^the history should be "(.*)"$/ do |history|
  page.find('.history_items .history_item:first div.display').text.should =~ /#{history}\.?/
end
Then /^the history should be empty$/ do
  page.should_not have_css '.history_items .history_item'
end
When /^I click the "Add History" button$/ do
  within '.history_items_section' do
    click_button 'Add'
  end
end
When /^I edit the history item to "([^"]*)"$/ do |history|
  step %{I fill in "taxt" with "#{history}"}
end
Then /^I should (not )?see the "Delete" button for the history item$/ do |should_not|
  selector = should_not ? :should_not : :should
  page.send selector, have_css('button.delete')
end
And /^I add a history item to "([^"]*)"(?: that includes a tag for "([^"]*)"?$)?/ do |taxon_name, tag_taxon_name|
  taxon = Taxon.find_by_name taxon_name
  if tag_taxon_name
    tag_taxon = Taxon.find_by_name tag_taxon_name
    taxt = Taxt.encode_taxon tag_taxon
  else
    taxt = 'Tag'
  end
  taxon.history_items.create! taxt: taxt
end
When /^I add a history item "(.*?)"/ do |text|
  step %{I click the "Add History" button}
  step %{I edit the history item to "#{text}"}
  step %{I save the history item}
end

Then /^I add a reference section "(.*?)"/ do |text|
  step %{I click the "Add" reference section button}
  step %{I fill in the references field with "#{text}"}
  step %{I save the reference section}
end

# references section
Then /^the reference section should be "(.*)"$/ do |reference|
  page.find('.reference_sections .reference_section:first div.display').text.should =~ /#{reference}\.?/
end
When /^I click the reference section/ do
  find('.reference_sections .reference_section:first div.display').click
end
When /^I fill in the references field with "([^"]*)"$/ do |references|
  step %{I fill in "references_taxt" with "#{references}"}
end
When /^I save the reference section$/ do
  within '.reference_sections .reference_section:first' do
    step %{I press "Save"}
  end
end
When /^I delete the reference section$/ do
  within '.reference_section:first' do
    step %{I press "Delete"}
  end
end
Then /^the reference section should be empty$/ do
  page.should_not have_css '.reference_sections .reference_section'
end
When /^I cancel the reference section's changes$/ do
  within '.reference_sections .reference_section:first' do
    step %{I press the "Cancel" button}
  end
end
When /^I click the "Add" reference section button$/ do
  within '.references_section' do
    click_button 'Add'
  end
end
Then /^I should (not )?see the "Delete" button for the reference/ do |should_not|
  selector = should_not ? :should_not : :should
  page.send selector, have_css('button.delete')
end

# synonym section
When /^I save the senior synonym$/ do
  step %{I press the senior synonym item "Save" button}
end
When /^I press the senior synonym item "([^"]*)" button$/ do |button|
  within '.senior_synonyms_section' do
    step %{I press "#{button}"}
  end
end
When /^I press the (?:junior )?synonym item "([^"]*)" button$/ do |button|
  within '.junior_synonyms_section' do
    step %{I press "#{button}"}
  end
end
When /^I click "(.*?)" beside the first junior synonym$/ do |button|
  within '.junior_synonyms_section .synonym_row' do
    step %{I press "#{button}"}
  end
end
When /^I click "(.*?)" beside the first senior synonym$/ do |button|
  within '.senior_synonyms_section .synonym_row' do
    step %{I press "#{button}"}
  end
end
When /^I fill in the junior synonym name with "([^"]*)"$/ do |name|
  within '.junior_synonyms_section .edit' do
    step %{I fill in "name" with "#{name}"}
  end
end
When /^I fill in the senior synonym name with "([^"]*)"$/ do |name|
  within '.senior_synonyms_section .edit' do
    step %{I fill in "name" with "#{name}"}
  end
end
