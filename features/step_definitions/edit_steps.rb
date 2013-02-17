# coding: UTF-8
When /^I save my changes$/ do
  step 'I press "Save"'
end

When /^I save my changes to the current reference$/ do
  within first('.current') do
    step 'I save my changes'
  end
end

When /^I save the form$/ do
  step 'I save my changes'
end

When /^I set the name to "([^"]*)"$/ do |name|
  step %{I fill in "taxon[name_attributes][epithet]" with "#{name}"}
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

