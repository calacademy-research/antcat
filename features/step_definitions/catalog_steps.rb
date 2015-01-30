# coding: UTF-8
Then /^I should (not )?see the reference key "([^"]+)"$/ do |should_not, text|
  selector = should_not ? :should_not : :should
  find(".reference_key", :text => text).send(selector, be_visible)
end

Then /^I should (not )?see the reference key expansion$/ do |should_not|
  selector = should_not ? :should_not : :should
  visible = should_not ? :false : :true

  find(".reference_key_expansion",visible: visible).send(selector, be_visible)
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

Then /^I should see the catalog entry for "([^"]*)"$/ do |taxon|
  page.should have_css('.header .taxon', text: taxon)
end

And /^the name in the header should be "([^"]*)"/ do |name|
  page.should have_css('.header .taxon', text: name)
end
