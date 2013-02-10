# coding: UTF-8
When /^I save my changes$/ do
  step 'I press "Save"'
  step 'I wait for a bit'
end

When /^I save the form$/ do
  step 'I save my changes'
end

When /^I set the genus name to "([^"]*)"$/ do |name|
  step %{I fill in "genus[name_attributes][epithet]" with "#{name}"}
end
