Given("there is a subspecies {string} which is a subspecies of {string}") do |subspecies_name, species_name|
  species = Species.find_by(name_cache: species_name)
  create :subspecies, name_string: subspecies_name, species: species, genus: species.genus
end

Given("there is a subspecies {string} which is a subspecies of {string} in the genus {string}") do |subspecies, species, genus|
  genus = create :genus, name_string: genus
  species = create :species, name_string: species, genus: genus
  create :subspecies, name_string: subspecies, species: species, genus: genus
end
