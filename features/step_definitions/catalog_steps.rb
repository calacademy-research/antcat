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
  page.send selector, have_css("#taxon_browser .#{rank}-test-hook")
end

Then /^I should see the catalog entry for "([^"]*)"$/ do |taxon|
  page.should have_css('.header .taxon', text: taxon)
end

And /^the name in the header should be "([^"]*)"/ do |name|
  page.should have_css('.header .taxon', text: name)
end

Then /^I should (not )?see the taxon browser$/ do |should_not|
  if should_not
    page.should have_no_css("#taxon_browser")
  else
    page.should have_css("#taxon_browser", visible: true)
  end
end

Then /^I toggle the taxon browser$/ do
  first(".toggle-taxon-browser-js-hook").click
end
