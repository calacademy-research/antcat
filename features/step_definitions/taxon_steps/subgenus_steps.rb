# frozen_string_literal: true

def there_is_a_subgenus_in_the_genus subgenus_name, genus_name
  genus = Genus.find_by(name_cache: genus_name) || create(:genus, name_string: genus_name)
  create :subgenus, name_string: subgenus_name, genus: genus
end
