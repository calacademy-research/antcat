# frozen_string_literal: true

# Taxon browser.
Then('{string} should be selected in the taxon browser') do |name|
  within '#taxon-browser-container' do
    expect(page).to have_css ".selected", text: name
  end
end

# Citations.
Given("there is a genus Lasius described in Systema Piezatorum") do
  genus = create :genus, name_string: 'Lasius'

  reference = create :article_reference, title: 'Systema Piezatorum'
  genus.protonym.authorship.update!(reference: reference)
end
