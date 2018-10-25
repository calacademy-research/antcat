Given("there is a subspecies {string}") do |name|
  create_subspecies name
end

Given("there is a subspecies {string} which is a subspecies of {string}") do |subspecies_name, species_name|
  create_subspecies subspecies_name, species: Species.find_by_name(species_name)
end

Given("there is a subspecies {string} without a species") do |subspecies_name|
  create_subspecies subspecies_name, species: nil
end

Given("a subspecies exists for that species with a name of {string}") do |name|
  subspecies_name = create :subspecies_name, name: name
  create :subspecies,
    name: subspecies_name,
    species: @species,
    genus: @species.genus
end

Given("there is a subspecies {string} which is a subspecies of {string} in the genus {string}") do |subspecies, species, genus|
  genus = create_genus genus
  species = create_species species, genus: genus
  create_subspecies subspecies, species: species, genus: genus
end
