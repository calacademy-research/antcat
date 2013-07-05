# coding: UTF-8
When /^I click the first search result$/ do
  step 'I click ".search_results .display:first"'
end

Then /^the authorship field should contain the reference by (\w+)$/ do |author|
  page.find('#authorship_field .display').text.should =~ /#{author}.*/
end

Then /^the authorship field should contain "([^"]*)"$/ do |contents|
  page.find('#authorship_field .display').text.should == contents
end

Then /^the current reference should be "([^"]*)"$/ do |contents|
  page.find('#popup .current .display').text.should == contents
end

Then /^the widget results should be "([^"]*)"$/ do |contents|
  page.find('#results').text.should == contents
end

Then /^the widget results should be the ID for "([^"]*)"$/ do |key|
  reference = find_reference_by_key key
  page.find('#results').text.should == reference.id.to_s
end

Then /^the widget results should be 0$/ do
  page.find('#results').text.should == '0'
end

Then /^the widget results should be the taxt for "Fisher 1995"$/ do
  reference = find_reference_by_key 'Fisher 1995'
  page.find('#results').text.should == "{Fisher, 1995b v}"
end

Then /^the current reference should be the first reference$/ do
  page.find('#popup .current .display').text.should == ''
end

Then /^I should not see the default reference button$/ do
  page.should_not have_css('button.default_reference')
end
