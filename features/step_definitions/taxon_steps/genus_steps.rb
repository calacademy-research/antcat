Given("there is a genus {string}") do |name|
  create_genus name
end

Given("there is a genus {string} with taxonomic history {string}") do |name, history|
  genus = create_genus name
  genus.history_items.create! taxt: history
end

Given("there is a genus {string} with protonym name {string}") do |name, protonym_name|
  genus = create_genus name
  genus.protonym.name = Name.find_by_name protonym_name
end

Given("there is a genus {string} with type name {string}") do |name, type_taxon_name|
  create_genus name, type_taxon: create_species(type_taxon_name)
end

Given("there is a genus {string} that is incertae sedis in the subfamily") do |name|
  create_genus name, incertae_sedis_in: 'subfamily'
end

Given("a genus exists with a name of {string} and a subfamily of {string}") do |name, parent_name|
  subfamily = Subfamily.find_by_name parent_name
  subfamily ||= create :subfamily, name: create(:subfamily_name, name: parent_name)

  create :genus,
    name: create(:genus_name, name: name),
    subfamily: subfamily,
    tribe: nil
end

Given("a genus exists with a name of {string} and no subfamily") do |name|
  genus_name = create :genus_name, name: name
  create :genus, name: genus_name, subfamily: nil, tribe: nil
end

Given(/a (fossil )?genus exists with a name of "(.*?)" and a tribe of "(.*?)"/) do |fossil, name, parent_name|
  tribe = Tribe.find_by_name parent_name
  create :genus,
    name: create(:genus_name, name: name),
    subfamily: tribe.subfamily,
    tribe: tribe,
    fossil: fossil.present?
end

Given("genus {string} exists in that tribe") do |name|
  create :genus,
    subfamily: @subfamily,
    tribe: @tribe,
    name: create(:genus_name, name: name)
end

Given("genus {string} exists in that subfamily") do |name|
  create :genus,
    subfamily: @subfamily,
    tribe: nil,
    name: create(:genus_name, name: name)
end

Given("there is a genus {string} with {string} name") do |name, gender|
  genus = create_genus name
  genus.name.update! gender: gender
end
