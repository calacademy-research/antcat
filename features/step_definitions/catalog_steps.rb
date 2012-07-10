# coding: UTF-8
When /I follow "All" in the subfamilies list/ do
  step %{I follow "All" within ".subfamilies"}
end

And /I hide tribes/ do
  step %{I follow "hide"}
end

When /I follow "All" in the subfamilies list/ do
  step %{I follow "All" within ".subfamilies"}
end

Then /^I should (not )?see the reference key "([^"]+)"$/ do |should_not, text|
  selector = should_not ? :should_not : :should
  find(".reference_key", :text => text).send(selector, be_visible)
end

Then /^I should (not )?see the reference key expansion$/ do |should_not|
  selector = should_not ? :should_not : :should
  find(".reference_key_expansion").send(selector, be_visible)
end

And /^I click the reference key$/ do
  find(".reference_key").click
end

And /^I click the reference key expansion$/ do
  find(".reference_key_expansion").click
end

Then /^I should (not )?see the tribes index$/ do |should_not|
  selector = should_not ? :should_not : :should
  page.send selector, have_css('.index .tribes')
end
