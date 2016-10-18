Given(/^there is a subspecies "([^"]*)"$/) do |name|
  create_subspecies name
end

Given(/^there is a subspecies "([^"]*)" which is a subspecies of "([^"]*)"$/) do |subspecies_name, species_name|
  create_subspecies subspecies_name, species: Species.find_by_name(species_name)
end

Given(/^there is a subspecies "([^"]*)" without a species/) do |subspecies_name|
  create_subspecies subspecies_name, species: nil
end

Given(/a subspecies exists for that species with a name of "(.*?)" and an epithet of "(.*?)" and a taxonomic history of "(.*?)"/) do |name, epithet, history|
  subspecies_name = create :subspecies_name,
    name: name,
    epithet: epithet,
    epithets: epithet
  subspecies = create :subspecies,
    name: subspecies_name,
    species: @species,
    genus: @species.genus
  history = 'none' unless history.present?
  subspecies.history_items.create! taxt: history
end

Given(/^subspecies "(.*?)" exists in that species$/) do |name|
  subspecies = create :subspecies,
    subfamily: @subfamily,
    genus: @genus,
    species: @species,
    name: create(:subspecies_name, name: name)
  subspecies.history_items.create! taxt: "#{name} history"
end

Given(/^there is a subspecies "([^"]*)" which is a subspecies of "([^"]*)" in the genus "([^"]*)"/) do |subspecies, species, genus|
  genus = create_genus genus
  species = create_species species, genus: genus
  create_subspecies subspecies, species: species, genus: genus
end
