# frozen_string_literal: true

def there_is_a_tribe_in_the_subfamily name, parent_name
  subfamily = Subfamily.find_by(name_cache: parent_name) || create(:subfamily, name_string: parent_name)
  create :tribe, name_string: name, subfamily: subfamily
end
