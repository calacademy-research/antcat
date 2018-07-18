Then(/^I should ?(not)? see the reference key "([^"]+)"$/) do |should_not, text|
  if should_not == "not"
    expect(page).to have_no_css ".reference_keey", text: text
  else
    expect(page).to have_css ".reference_keey", text: text
  end
end

Then(/^I should (not )?see the reference key expansion$/) do |should_not|
  if should_not
    expect(page).to have_no_css ".reference_keey_expansion"
  else
    expect(page).to have_css ".reference_keey_expansion"
  end
end

When("I click the reference key") do
  find(".reference_keey").click
end

When("I click the reference key expansion") do
  find(".reference_keey_expansion").click
end

Then("I should see the catalog entry for {string}") do |taxon|
  step %(the name in the header should be "#{taxon}")
end

Then("the name in the header should be {string}") do |name|
  expect(page).to have_css '.header .name', text: name
end

When("I fill in the catalog search box with {string}") do |search_term|
  find("#desktop-lower-menu #qq").set search_term
end

When('I press "Go" by the catalog search box') do
  # TODO fix mobile
  within "#desktop-lower-menu" do
    step 'I press "Go"'
  end
end

Given("the maximum number of taxa to load in each tab is {int}") do |number|
  allow_any_instance_of(TaxonBrowser::Browser).
    to receive(:max_taxa_to_load).
    and_return number.to_i
end

Given("Atta has a history section item with two linked references, of which one does not exists") do
  reference = create :article_reference, citation_year: 2000,
    author_names: [create(:author_name, name: "Batiatus, Q.")]
  taxt = "{ref #{reference.id}}; {ref 99999}"

  taxon = Taxon.find_by name_cache: "Atta"
  taxon.reference_sections << ReferenceSection.create!(references_taxt: taxt)
end
