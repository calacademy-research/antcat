Given("the Formicidae family exists") do
  create :family, name_string: "Formicidae"
end

Given("Formicidae exists with a history item {string}") do |taxt|
  taxon = create :family, name_string: "Formicidae"
  create :taxon_history_item, taxt: taxt, taxon: taxon
end
