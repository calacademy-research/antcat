# coding: UTF-8
When /^I click the first search result in the popup$/ do
  step 'I click "#popup .search_results .display:first"'
end

Then /^the field should contain the reference by "(\w+)" in the popup$/ do |author|
  page.find('#popup .current .display').text.should =~ /#{author}.*/
end

Then /^the field should contain "([^"]*)" in the popup$/ do |contents|
  page.find('#popup .display').text.should == contents
end
