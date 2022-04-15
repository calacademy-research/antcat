# frozen_string_literal: true

# Taxon browser.
Then('{string} should be selected in the taxon browser') do |name|
  within '#taxon-browser-new' do
    expect(page).to have_css ".selected", text: name
  end
end

# TODO: Remove hack with 'And I select the taxon browser tab ".taxon-browser-tab-0"'.
When("I select the taxon browser tab {string}") do |tab_css_selector|
  find(tab_css_selector, visible: false).click
end

# Citations.
Given("there is a genus Lasius described in Systema Piezatorum") do
  genus = create :genus, name_string: 'Lasius'

  reference = create :any_reference, title: 'Systema Piezatorum'
  genus.protonym.authorship.update!(reference: reference)
end
