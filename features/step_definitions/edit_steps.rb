# coding: UTF-8
When /^I save my changes$/ do
  step 'I press "Save"'
end

When /^I save the form$/ do
  step 'I save my changes'
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
  within '.history_section' do
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
