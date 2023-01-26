# frozen_string_literal: true

Given("there is a genus {string}") do |name|
  there_is_a_genus name
end
def there_is_a_genus name
  create :genus, name_string: name
end

Given("there is a genus {string} in the subfamily {string}") do |name, parent_name|
  there_is_a_genus_in_the_subfamily name, parent_name
end
def there_is_a_genus_in_the_subfamily name, parent_name
  subfamily = Subfamily.find_by(name_cache: parent_name) || create(:subfamily, name_string: parent_name)
  create :genus, name_string: name, subfamily: subfamily, tribe: nil
end

Given("there is a genus {string} in the tribe {string}") do |name, parent_name|
  there_is_a_genus_in_the_tribe name, parent_name
end
def there_is_a_genus_in_the_tribe name, parent_name
  tribe = Tribe.find_by(name_cache: parent_name) || create(:tribe, name_string: parent_name)
  create :genus, name_string: name, subfamily: tribe.subfamily, tribe: tribe
end
