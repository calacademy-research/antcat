Given("there is a tribe {string}") do |name|
  create_tribe name
end

Given(/a tribe exists with a name of "(.*?)"(?: and a subfamily of "(.*?)")?(?: and a taxonomic history of "(.*?)")?/) do |taxon_name, parent_name, history|
  subfamily = Subfamily.find_by_name parent_name
  subfamily ||= create :subfamily, name: create(:name, name: parent_name)
  taxon = create :tribe,
    name: create(:name, name: taxon_name),
    subfamily: subfamily

  history = 'none' unless history.present?
  taxon.history_items.create! taxt: history
end

Given("tribe {string} exists in that subfamily") do |name|
  @tribe = create :tribe,
    subfamily: @subfamily,
    name: create(:tribe_name, name: name)
  @tribe.history_items.create! taxt: "#{name} history"
end
