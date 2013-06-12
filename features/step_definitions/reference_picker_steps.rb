# coding: UTF-8
When /^I click the first search result$/ do
  step 'I click "#authorship_field .search_results .display:first"'
end

Then /^the authorship field should contain the reference by (\w+)$/ do |author|
  page.find('#authorship_field .display').text.should =~ /#{author}.*/
end

Then /^the authorship field should contain "([^"]*)"$/ do |contents|
  page.find('#authorship_field .display').text.should == contents
end
