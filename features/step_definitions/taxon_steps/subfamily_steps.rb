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
  step %{there is a subfamily "#{taxon_name}"}
end

Given(/^there is an invalid subfamily Invalidinae$/) do
  name = create :subfamily_name, name: "Invalidinae"
  create :subfamily, name: name, status: "synonym"
end
