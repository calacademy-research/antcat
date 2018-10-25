Then(/^I should ?(not)? see the reference key$/) do |should_not|
  if should_not == "not"
    expect(page).to have_no_css ".expandable-reference-key"
  else
    expect(page).to have_css ".expandable-reference-key"
  end
end

Then(/^I should (not )?see the reference key expansion$/) do |should_not|
  if should_not
    expect(page).to have_no_css ".expandable-reference-content"
  else
    expect(page).to have_css ".expandable-reference-content"
  end
end

When("I click the reference key") do
  find(".expandable-reference-key").click
end

When("I click the reference key expansion") do
  find(".expandable-reference-content").click
end

Then("the name in the header should be {string}") do |name|
  expect(page).to have_css '.header .name', text: name
end

When("I fill in the catalog search box with {string}") do |search_term|
  find("#desktop-lower-menu #qq").set search_term
end

When('I press "Go" by the catalog search box') do
  # TODO fix mobile
  within "#catalog-search-form-test-hook" do
    step 'I press "Go"'
  end
end

Given("the maximum number of taxa to load in each tab is {int}") do |number|
  allow_any_instance_of(TaxonBrowser::Browser).
    to receive(:max_taxa_to_load).
    and_return number.to_i
end
