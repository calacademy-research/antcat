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

Then /^I should (not )?see the (\w+) index$/ do |should_not, rank|
  selector = should_not ? :should_not : :should
  page.send selector, have_css(".index .#{rank}")
end

Then /^I should (not )?see that "([^"]*)" is a synonym of "([^"]*)"$/ do |should_not, junior, senior|
  selector = should_not ? :should_not : :should
  page.should have_css('.header .taxon', text: junior)
  page.send selector, have_css('.header .status', text: "synonym of #{senior}")
end

Then /^I should see the catalog entry for "([^"]*)"$/ do |taxon|
  page.should have_css('.header .taxon', text: taxon)
end

And /^there should be an editing history record showing that the new junior synonym is "([^"]*)" and the new senior synonym is "([^"]*)"/ do |junior, senior|
  editing_history = ReverseSynonymyEdit.first
  editing_history.new_junior.name.to_s.should == junior
  editing_history.new_senior.name.to_s.should == senior
  editing_history.user.should_not be_blank
end
Then /^there should be an editing history record showing that the taxon is "([^"]*)" and the old species was "([^"]*)"$/ do |taxon, old_species|
  editing_history = ElevateSubspeciesEdit.first
  editing_history.taxon.name.to_s.should == taxon
  editing_history.old_species.name.to_s.should == old_species
  editing_history.user.should_not be_blank
end

Then /^I should not be on (.+)$/ do |page_name|
  current_path.should_not == path_to(page_name)
end
