# coding: UTF-8
When /^I click the first search result$/ do
  step 'I click ".search_results .display:first"'
end

Then /^the field should contain the reference by (\w+)$/ do |author|
  page.find('.current .display').text.should =~ /#{author}.*/
end

Then /^the field should contain "([^"]*)"$/ do |contents|
  page.find('.current .display').text.should == contents
end

When /^I click the expand icon$/ do
  step 'I click ".current .display"'
end
