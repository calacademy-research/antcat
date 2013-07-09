# coding: UTF-8
Then /^I should not see a change for "(.*?)"$/ do |name|
  page.should_not have_css('.name', text: name)
end

Then /^I should see a change for "(.*?)"$/ do |name|
  pending # express the regexp above with the code you wish you had
end

When /^I add the genus "(.*?)"$/ do |name|
  step %{there is a genus "Eciton"}
  step %{I go to the catalog page for "Formicinae"}
  step %{I press "Edit"}
  step %{I press "Add genus"}
  step %{I click the name field}
  step %{I set the name to "Atta"}
  step %{I press "OK"}
  step %{I click the protonym name field}
  step %{I set the protonym name to "Eciton"}
  step %{I press "OK"}
  step %{I click the authorship field}
  step %{I search for the author "Fisher"}
  step %{I click the first search result}
  step %{I press "OK"}
  step %{I click the type name field}
  step %{I set the type name to "Atta major"}
  step %{I press "OK"}
  step %{I press "Add this name"}
  step %{I save my changes}
end
