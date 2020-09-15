# frozen_string_literal: true

Given("there is a subspecies {string} in the species {string}") do |subspecies_name, species_name|
  species = Species.find_by!(name_cache: species_name)
  create :subspecies, name_string: subspecies_name, species: species, genus: species.genus
end
