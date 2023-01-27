# frozen_string_literal: true

def there_is_a_species_in_the_genus species_name, genus_name
  genus = Genus.find_by(name_cache: genus_name) || create(:genus, name_string: genus_name)
  create :species, name_string: species_name, genus: genus
end

def there_is_a_species_which_is_a_junior_synonym_of species_name, senior_name
  senior = create :species, name_string: senior_name
  create :species, :synonym, name_string: species_name, current_taxon: senior
end
