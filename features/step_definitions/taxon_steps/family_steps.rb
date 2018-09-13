Given("the Formicidae family exists") do
  reference = create :article_reference,
    author_names: [create(:author_name, name: 'Latreille, I.')],
    citation_year: '1809',
    title: 'Ants'

  protonym = create :protonym,
    name: create(:subfamily_name),
    authorship: create(:citation, reference: reference)

  create :family,
    name: create(:family_name, name: "Formicidae"),
    protonym: protonym
end

Given("Formicidae has a history item {string}") do |string|
  Family.first.history_items << create(:taxon_history_item, taxt: string)
end
