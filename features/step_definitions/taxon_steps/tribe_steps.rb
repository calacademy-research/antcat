# frozen_string_literal: true

Given("there is a tribe {string}") do |name|
  there_is_a_tribe name
end
def there_is_a_tribe name
  create :tribe, name_string: name
end

Given("there is a tribe {string} in the subfamily {string}") do |name, parent_name|
  there_is_a_tribe_in_the_subfamily name, parent_name
end
def there_is_a_tribe_in_the_subfamily name, parent_name
  subfamily = Subfamily.find_by(name_cache: parent_name) || create(:subfamily, name_string: parent_name)
  create :tribe, name_string: name, subfamily: subfamily
end
