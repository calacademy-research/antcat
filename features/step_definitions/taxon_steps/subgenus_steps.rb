# frozen_string_literal: true

Given("there is a subgenus {string} in the genus {string}") do |subgenus_name, genus_name|
  there_is_a_subgenus_in_the_genus subgenus_name, genus_name
end
def there_is_a_subgenus_in_the_genus subgenus_name, genus_name
  genus = Genus.find_by(name_cache: genus_name) || create(:genus, name_string: genus_name)
  create :subgenus, name_string: subgenus_name, genus: genus
end
