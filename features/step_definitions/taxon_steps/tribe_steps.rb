Given("there is a tribe {string}") do |name|
  create :tribe, name: create(:tribe_name, name: name)
end

Given("a tribe exists with a name of {string} and a subfamily of {string}") do |name, parent_name|
  subfamily = Subfamily.find_by_name parent_name
  subfamily ||= create :subfamily, name: create(:subfamily_name, name: parent_name)
  create :tribe,
    name: create(:tribe_name, name: name),
    subfamily: subfamily
end

Given("tribe {string} exists in that subfamily") do |name|
  create :tribe,
    subfamily: @subfamily,
    name: create(:tribe_name, name: name)
end
