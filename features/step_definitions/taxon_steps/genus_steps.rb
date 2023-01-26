# frozen_string_literal: true

def there_is_a_genus name
  create :genus, name_string: name
end

def there_is_a_genus_in_the_subfamily name, parent_name
  subfamily = Subfamily.find_by(name_cache: parent_name) || create(:subfamily, name_string: parent_name)
  create :genus, name_string: name, subfamily: subfamily, tribe: nil
end

def there_is_a_genus_in_the_tribe name, parent_name
  tribe = Tribe.find_by(name_cache: parent_name) || create(:tribe, name_string: parent_name)
  create :genus, name_string: name, subfamily: tribe.subfamily, tribe: tribe
end
