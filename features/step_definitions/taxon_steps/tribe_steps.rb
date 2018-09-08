Given("there is a tribe {string}") do |name|
  create_tribe name
end

Given("a tribe exists with a name of {string} and a subfamily of {string}") do |taxon_name, parent_name|
  subfamily = Subfamily.find_by_name parent_name
  subfamily ||= create :subfamily, name: create(:name, name: parent_name)
  taxon = create :tribe,
    name: create(:name, name: taxon_name),
    subfamily: subfamily
end

Given("tribe {string} exists in that subfamily") do |name|
  @tribe = create :tribe,
    subfamily: @subfamily,
    name: create(:tribe_name, name: name)
  @tribe.history_items.create! taxt: "#{name} history"
end
