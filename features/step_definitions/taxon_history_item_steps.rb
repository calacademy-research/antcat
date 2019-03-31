Given("there is a taxon history item with the taxt {string}") do |taxt|
  TaxonHistoryItem.create taxt: taxt, taxon: create(:family)
end

Given("there is a history item with Forel 1878 Bolton key I want to convert") do
  create :article_reference, author_names: [create(:author_name, name: 'Forel')],
    citation_year: '1878b', bolton_key: 'Forel 1878'
  TaxonHistoryItem.create taxt: "Forel, 1878:", taxon: create(:family)
end
