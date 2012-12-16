# coding: UTF-8
When /^I click "([^"]*)"$/ do |selector|
  find(selector).click
end

When /^I click the first search result$/ do
  step 'I click ".search_results .display"'
end

Then /^the field should contain the reference by (\w+)$/ do |author|
  page.find('.current .display').text.should =~ /#{author}.*/
end
