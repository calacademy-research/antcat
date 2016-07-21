Then /^I should (not )?see the reference key "([^"]+)"$/ do |should_not, text|
  selector = should_not ? :should_not : :should
  find(".reference_key", text: text).send(selector, be_visible)
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

Then /^I should see the catalog entry for "([^"]*)"$/ do |taxon|
  page.should have_css('.header .taxon', text: taxon)
end

And /^the name in the header should be "([^"]*)"/ do |name|
  page.should have_css('.header .taxon', text: name)
end

When /I fill in the catalog search box with "(.*?)"/ do |search_term|
  find("#desktop-lower-menu #qq").set search_term
end

When /I press "Go" by the catalog search box/ do
  # TODO fix mobile
  within "#desktop-lower-menu" do
    step 'I press "Go"'
  end
end

Then "I should not see any search results" do
  page.should_not have_css "#search_results"
end
