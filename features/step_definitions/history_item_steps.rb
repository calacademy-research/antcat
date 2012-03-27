# coding: UTF-8
Then /^the history should be "(.*)"$/ do |history|
  page.find('div.display').text.should =~ /#{history}\.?/
end

When /^I click the edit icon$/ do
  step 'I follow "edit"'
end

When /^I edit the history item to "([^"]*)"$/ do |history|
  step %{I fill in "taxt_editor" with "#{history}"}
end

When /^I save my changes$/ do
  step 'I press "Save"'
  step 'I wait for a bit'
end

Given /^there is a reference for "Bolton, 2005"$/ do
  @reference = Factory :article_reference, :author_names => [Factory(:author_name, :name => 'Bolton')], :citation_year => '2005'
end

Given /^I edit the history item to include that reference$/ do
  key = Taxt.id_for_editable @reference.id
  step %{I edit the history item to "{#{key}}"}
end

Then /^I should see an error message about the unfound reference$/ do
  step %{I should see "The reference '{123}' could not be found. Was the ID changed?"}
end

When /^I search for "([^"]*)"$/ do |search_term|
  step "I fill in the search box with \"#{search_term}\""
  step "I press \"Go\" by the search box"
end

When /^I search for the authors "([^"]*)"$/ do |authors|
  step %{I select "Search for author(s)" from "search_selector"}
  step %{I fill in the search box with "Bolton, B.;Fisher, B."}
  step %{I press "Go" by the search box}
end
