Given("there is a tribe {string}") do |name|
  create :tribe, name_string: name
end

Given("a tribe exists with a name of {string} and a subfamily of {string}") do |name, parent_name|
  subfamily = Subfamily.find_by(name_cache: parent_name) || create(:subfamily, name_string: parent_name)
  create :tribe, name_string: name, subfamily: subfamily
end
