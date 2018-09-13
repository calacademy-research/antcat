Given("there is a tribe {string}") do |name|
  create_tribe name
end

Given("a tribe exists with a name of {string} and a subfamily of {string}") do |name, parent_name|
  subfamily = Subfamily.find_by_name parent_name
  subfamily ||= create :subfamily, name: create(:name, name: parent_name)
  create :tribe,
    name: create(:name, name: name),
    subfamily: subfamily
end

Given("tribe {string} exists in that subfamily") do |name|
  @tribe = create :tribe,
    subfamily: @subfamily,
    name: create(:tribe_name, name: name)
end
