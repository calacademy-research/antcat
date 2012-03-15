# coding: UTF-8
Then /^the history should be "(.*)"$/ do |history|
  page.should have_css '.history .display', text: history
end

When /^I click the edit icon$/ do
  step 'I follow "edit"'
end

When /^I edit the history item to "([^"]*)"$/ do |history|
  step %{I fill in "taxt_editor" with "#{history}"}
end

When /^I save my changes$/ do
  step 'I click "Save"'
end

