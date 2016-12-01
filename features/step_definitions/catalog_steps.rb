Then(/^I should ?(not)? see the reference key "([^"]+)"$/) do |should_not, text|
  if should_not == "not"
    expect(page).to have_no_css ".reference_keey", text: text
  else
    expect(page).to have_css ".reference_keey", text: text
  end
end

Then(/^I should (not )?see the reference key expansion$/) do |should_not|
  selector = should_not ? :should_not : :should
  visible = should_not ? :false : :true

  find(".reference_keey_expansion", visible: visible).send(selector, be_visible)
end

When(/^I click the reference key$/) do
  find(".reference_keey").click
end

When(/^I click the reference key expansion$/) do
  find(".reference_keey_expansion").click
end

Then(/^I should see the catalog entry for "([^"]*)"$/) do |taxon|
  step %{the name in the header should be "#{taxon}"}
end

Then(/^the name in the header should be "([^"]*)"/) do |name|
  expect(page).to have_css '.header .name', text: name
end

When(/I fill in the catalog search box with "(.*?)"/) do |search_term|
  find("#desktop-lower-menu #qq").set search_term
end

When(/I press "Go" by the catalog search box/) do
  # TODO fix mobile
  within "#desktop-lower-menu" do
    step 'I press "Go"'
  end
end

Then("I should not see any search results") do
  expect(page).to_not have_css "#search_results"
end

Given(/^the maximum number of taxa to load in each tab is (\d+)$/) do |number|
  allow_any_instance_of(Catalog::TaxonBrowser::Browser)
    .to receive(:max_taxa_to_load)
    .and_return number.to_i
end
