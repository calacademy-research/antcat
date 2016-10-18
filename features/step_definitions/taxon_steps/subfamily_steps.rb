Given(/there is a subfamily "([^"]*)" with taxonomic history "([^"]*)"$/) do |taxon_name, history|
  name = create :subfamily_name, name: taxon_name
  taxon = create :subfamily, name: name
  taxon.history_items.create! taxt: history
end

Given(/there is a subfamily "([^"]*)" with a reference section "(.*?)"$/) do |taxon_name, references|
  name = create :subfamily_name, name: taxon_name
  taxon = create :subfamily, name: name
  taxon.reference_sections.create! references_taxt: references
end

Given(/there is a subfamily "([^"]*)"$/) do |taxon_name|
  name = create :subfamily_name, name: taxon_name
  @subfamily = create :subfamily, name: name
end

Given(/^subfamily "(.*?)" exists$/) do |taxon_name|
  name = create :subfamily_name, name: taxon_name
  @subfamily = create :subfamily, name: name
  @subfamily.history_items.create! taxt: "#{name} history"
end

Given(/^the unavailable subfamily "(.*?)" exists$/) do |name|
  @subfamily = create :subfamily,
    status: 'unavailable',
    name: create(:subfamily_name, name: name)
  @subfamily
end
