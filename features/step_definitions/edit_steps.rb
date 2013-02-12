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

When /^I set the genus name to "([^"]*)"$/ do |name|
  step %{I fill in "genus[name_attributes][epithet]" with "#{name}"}
end

When /^I save my changes to the first reference$/ do
  within first('.reference') do
    step 'I save my changes'
  end
end

