Given("there is a genus {string}") do |name|
  create :genus, name_string: name
end

Given("there is a genus {string} with a history item {string}") do |name, taxt|
  taxon = create :genus, name_string: name
  create :taxon_history_item, taxt: taxt, taxon: taxon
end

Given("there is a genus {string} with type name {string}") do |name, type_taxon_name|
  create :genus, name_string: name, type_taxon: create(:species, name_string: type_taxon_name)
end

Given("a genus exists with a name of {string} and a subfamily of {string}") do |name, parent_name|
  subfamily = Subfamily.find_by(name_cache: parent_name) || create(:subfamily, name_string: parent_name)
  create :genus, name_string: name, subfamily: subfamily, tribe: nil
end

Given("a genus exists with a name of {string} and a tribe of {string}") do |name, parent_name|
  tribe = Tribe.find_by(name_cache: parent_name) || create(:tribe, name_string: parent_name)
  create :genus, name_string: name, subfamily: tribe.subfamily, tribe: tribe
end
