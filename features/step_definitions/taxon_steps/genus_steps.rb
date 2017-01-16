Given(/^there is a genus "([^"]*)"$/) do |name|
  create_genus name
end

Given(/^there is a genus "([^"]*)" with taxonomic history "(.*?)"$/) do |name, history|
  genus = create_genus name
  genus.history_items.create! taxt: history
end

Given(/^there is a genus "([^"]*)" with protonym name "(.*?)"$/) do |name, protonym_name|
  genus = create_genus name
  genus.protonym.name = Name.find_by_name protonym_name if protonym_name
end

Given(/^there is a genus "([^"]*)" with type name "(.*?)"$/) do |name, type_name|
  genus = create_genus name
  genus.type_name = Name.find_by_name type_name
end

Given(/^there is a genus "([^"]*)" that is incertae sedis in the subfamily$/) do |name|
  genus = create_genus name
  genus.update_attribute :incertae_sedis_in, 'subfamily'
end

Given(/^a genus exists with a name of "(.*?)" and a subfamily of "(.*?)"(?: and a taxonomic history of "(.*?)")?(?: and a status of "(.*?)")?$/) do |taxon_name, parent_name, history, status|
  status ||= 'valid'
  subfamily = Subfamily.find_by_name parent_name
  subfamily ||= create :subfamily, name: create(:name, name: parent_name)

  taxon = create :genus,
    name: create(:name, name: taxon_name),
    subfamily: subfamily,
    tribe: nil,
    status: status

  history = 'none' unless history.present?
  taxon.history_items.create! taxt: history
end

Given(/^a non-displayable genus exists with a name of "(.*?)" and a subfamily of "(.*?)"$/) do |taxon_name, subfamily_name|
  subfamily = Subfamily.find_by_name subfamily_name
  subfamily ||= create :subfamily, name: create(:name, name: subfamily_name)
  create :genus,
    name: create(:name, name: taxon_name),
    subfamily: subfamily,
    tribe: nil,
    status: 'valid',
    display: false
end

Given(/a genus exists with a name of "(.*?)" and no subfamily(?: and a taxonomic history of "(.*?)")?/) do |taxon_name, history|
  another_genus = create :genus_name, name: taxon_name

  genus = create :genus, name: another_genus, subfamily: nil, tribe: nil
  history = 'none' unless history.present?
  genus.history_items.create! taxt: history
end

Given(/a (fossil )?genus exists with a name of "(.*?)" and a tribe of "(.*?)"(?: and a taxonomic history of "(.*?)")?/) do |fossil, taxon_name, parent_name, history|
  tribe = Tribe.find_by_name parent_name
  taxon = create :genus,
    name: create(:name, name: taxon_name),
    subfamily: tribe.subfamily,
    tribe: tribe,
    fossil: fossil.present?

  history = 'none' unless history.present?
  taxon.history_items.create! taxt: history
end

Given(/^genus "(.*?)" exists in that tribe$/) do |name|
  @genus = create :genus,
    subfamily: @subfamily,
    tribe: @tribe,
    name: create(:genus_name, name: name)
  @genus.history_items.create! taxt: "#{name} history"
end

Given(/^genus "(.*?)" exists in that subfamily/) do |name|
  @genus = create :genus,
    subfamily: @subfamily,
    tribe: nil,
    name: create(:genus_name, name: name)
  @genus.history_items.create! taxt: "#{name} history"
end

Given(/^there is a genus "([^"]*)" with "([^"]*)" name$/) do |name, gender|
  genus = create_genus name
  genus.name.update! gender: gender
end
