# coding: UTF-8
When /^I click the first search result$/ do
  step 'I click ".search_results .display:first"'
end

Then /^the authorship field should contain the reference by (\w+)$/ do |author|
  page.find('#authorship_field .display').text.should =~ /#{author}.*/
end

Then /^the authorship field should contain "([^"]*)"$/ do |contents|
  page.should have_css '#authorship_field .display', text: contents
end

Then /^the current reference should be "([^"]*)"$/ do |contents|
  page.should have_css '#popup .current .display', text: contents
end

Then /^the widget results should be "([^"]*)"$/ do |contents|
  page.should have_css '#results', text: contents
end

Then /^the widget results should be the ID for "([^"]*)"$/ do |key|
  reference = find_reference_by_key key
  step %{the widget results should be "#{reference.id.to_s}"}
end

Then /^the widget results should be the taxt for "Fisher 1995"$/ do
  reference = find_reference_by_key 'Fisher 1995'
  step %{the widget results should be "{Fisher, 1995b v}"}
end

Then /^I should not see the default reference button$/ do
  page.should_not have_css('button.default_reference')
end
