# Taxon browser.
Then('{string} should be selected in the taxon browser') do |name|
  within '#taxon-browser-container' do
    expect(page).to have_css ".selected", text: name
  end
end

# HACK.
Given("the maximum number of taxa to load in each tab is {int}") do |number|
  allow_any_instance_of(TaxonBrowser::Browser).
    to receive(:max_taxa_to_load).
    and_return number.to_i
end
