# coding: UTF-8
#Then /^the history should be "(.*)"$/ do |history|
  #page.find('div.display').text.should =~ /#{history}\.?/
#end

#When /^I edit the history item to "([^"]*)"$/ do |history|
  #step %{I fill in "taxt_editor" with "#{history}"}
#end

#Given /^I edit the history item to include that reference$/ do
  #key = Taxt.id_for_editable @reference.id
  #step %{I edit the history item to "{#{key}}"}
#end

#Then /^I should see an error message about the unfound reference$/ do
  #step %{I should see "The reference '{123}' could not be found. Was the ID changed?"}
#end

