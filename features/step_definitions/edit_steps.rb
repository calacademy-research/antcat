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

# history item section
When /^I press the history item "([^"]*)" button$/ do |button|
  within '.not_history_item_template' do
    step %{I press "#{button}"}
  end
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

When /^I set the name to "([^"]*)"$/ do |name|
  step %{I fill in "taxon[name_attributes][epithet]" with "#{name}"}
end

When /^I set the protonym name to "([^"]*)"$/ do |name|
  step %{I fill in "name_string" with "#{name}"}
end

When /^I set the type name to "([^"]*)"$/ do |name|
  step %{I fill in "name_string" with "#{name}"}
end

When /^I save my changes to the first reference$/ do
  within first('.reference') do
    step 'I save my changes'
  end
end

When /^I put the cursor in the headline notes edit box$/ do
  find('#taxon_headline_notes_taxt').click
end

When /^I fill in the name with "([^"]*)"$/ do |value|
  step %{I fill in "name_string" with "#{value}"}
end

And /^I click the authorship field$/ do
  step %{I click "#authorship_field .display_button"}
end

When /I click the name field/ do
  step %{I click "#test_name_field .display_button"}
end

When /I click the protonym name field/ do
  find('#protonym_name_field .display_button').click
end

When /I click the type name field/ do
  find('#type_name_field .display_button').click
end

When /^I click the history item$/ do
  find('.not_history_item_template div.display').click
end

Then /^the history should be "(.*)"$/ do |history|
  page.find('.not_history_item_template div.display').text.should =~ /#{history}\.?/
end

Then /^the history should be empty$/ do
  page.should_not have_css '.not_history_item_template'
end

When /^I click the "Add History" button$/ do
  within '.history_items_section' do
    click_button 'Add'
  end
end

When /^I edit the history item to "([^"]*)"$/ do |history|
  step %{I fill in "taxt" with "#{history}"}
end

When /^I press that history item's "Insert Name" button$/ do
  within '.history_item:first' do
    click_button 'Insert Name'
  end
end

Then /^I should see an error message about the unfound reference$/ do
  step %{I should see "The reference '{123}' could not be found. Was the ID changed?"}
end

Then /^I should (not )?see the "Delete" button for the history item$/ do |should_not|
  selector = should_not ? :should_not : :should
  page.send selector, have_css('button.delete')
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
