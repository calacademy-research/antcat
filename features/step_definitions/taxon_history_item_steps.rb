Given("there is a history item {string}") do |taxt|
  create :taxon_history_item, taxt: taxt
end

Given("there is a history item with Forel 1878 Bolton key I want to convert") do
  create :article_reference, author_names: [create(:author_name, name: 'Forel')],
    citation_year: '1878b', bolton_key: 'Forel 1878'
  create :taxon_history_item, taxt: "Forel, 1878:"
end
