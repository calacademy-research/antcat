Given("there is a genus {string}") do |name|
  create :genus, name_string: name
end

Given("there is a genus {string} with taxonomic history {string}") do |name, history|
  genus = create :genus, name_string: name
  genus.history_items.create! taxt: history
end

Given("there is a genus {string} with type name {string}") do |name, type_taxon_name|
  create :genus, name_string: name, type_taxon: create(:species, name_string: type_taxon_name)
end

Given("there is a genus {string} that is incertae sedis in the subfamily") do |name|
  create :genus, name_string: name, incertae_sedis_in: 'subfamily'
end

Given("a genus exists with a name of {string} and a subfamily of {string}") do |name, parent_name|
  subfamily = Subfamily.find_by(name_cache: parent_name)
  subfamily ||= create :subfamily, name_string: parent_name

  create :genus, name_string: name, subfamily: subfamily, tribe: nil
end

Given("a genus exists with a name of {string} and no subfamily") do |name|
  create :genus, name_string: name, subfamily: nil, tribe: nil
end

Given(/a (fossil )?genus exists with a name of "(.*?)" and a tribe of "(.*?)"/) do |fossil, name, parent_name|
  tribe = Tribe.find_by(name_cache: parent_name)
  create :genus, name_string: name, subfamily: tribe.subfamily, tribe: tribe, fossil: fossil.present?
end

Given("genus {string} exists in that subfamily") do |name|
  create :genus, name_string: name, subfamily: @subfamily, tribe: nil
end

Given("there is a genus {string} with {string} name") do |name, gender|
  genus = create :genus, name_string: name
  genus.name.update! gender: gender
end
