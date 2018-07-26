Given("subgenus {string} exists in that genus") do |name|
  epithet = name.match(/\((.*?)\)/)[1]
  name_object = create :subgenus_name, name: name, epithet: epithet

  @subgenus = create :subgenus,
    subfamily: @subfamily,
    tribe: @tribe,
    genus: @genus,
    name: name_object
  @subgenus.history_items.create! taxt: "#{name_object.name} history"
end
