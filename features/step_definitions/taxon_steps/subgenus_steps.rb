Given("subgenus {string} exists in that genus") do |name|
  epithet = name.match(/\((.*?)\)/)[1]
  subgenus_name = create :subgenus_name, name: name, epithet: epithet

  create :subgenus,
    subfamily: @subfamily,
    tribe: @tribe,
    genus: @genus,
    name: subgenus_name
end
