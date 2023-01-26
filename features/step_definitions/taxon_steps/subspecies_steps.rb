# frozen_string_literal: true

def there_is_a_subspecies_in_the_species subspecies_name, species_name
  species = Species.find_by!(name_cache: species_name)
  create :subspecies, name_string: subspecies_name, species: species, genus: species.genus
end
