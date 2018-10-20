Given("there is a subgenus {string}") do |name|
  subgenus_name = create :subgenus_name, name: name
  create :subgenus, name: subgenus_name
end
