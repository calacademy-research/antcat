# frozen_string_literal: true

# Tribe.
def there_is_a_tribe_in_the_subfamily name, parent_name
  subfamily = Subfamily.find_by(name_cache: parent_name) || create(:subfamily, name_string: parent_name)
  create :tribe, name_string: name, subfamily: subfamily
end

# Genus.
def there_is_a_genus_in_the_subfamily name, parent_name
  subfamily = Subfamily.find_by(name_cache: parent_name) || create(:subfamily, name_string: parent_name)
  create :genus, name_string: name, subfamily: subfamily, tribe: nil
end

def there_is_a_genus_in_the_tribe name, parent_name
  tribe = Tribe.find_by(name_cache: parent_name) || create(:tribe, name_string: parent_name)
  create :genus, name_string: name, subfamily: tribe.subfamily, tribe: tribe
end

# Subgenus.
def there_is_a_subgenus_in_the_genus subgenus_name, genus_name
  genus = Genus.find_by(name_cache: genus_name) || create(:genus, name_string: genus_name)
  create :subgenus, name_string: subgenus_name, genus: genus
end

# Species.
def there_is_a_species_in_the_genus species_name, genus_name
  genus = Genus.find_by(name_cache: genus_name) || create(:genus, name_string: genus_name)
  create :species, name_string: species_name, genus: genus
end

def there_is_a_species_which_is_a_junior_synonym_of species_name, senior_name
  senior = create :species, name_string: senior_name
  create :species, :synonym, name_string: species_name, current_taxon: senior
end

def there_is_a_subspecies_in_the_species subspecies_name, species_name
  species = Species.find_by!(name_cache: species_name)
  create :subspecies, name_string: subspecies_name, species: species, genus: species.genus
end
