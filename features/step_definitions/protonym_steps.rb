# frozen_string_literal: true

def there_is_a_genus_protonym name_string
  name = create(:genus_name, name: name_string)
  create :protonym, :genus_group, name: name
  create :protonym, :genus_group, name: create(:genus_name, name: name_string)
end

def there_is_a_species_protonym_with_pages_and_form_page_9_dealate_queen name_string
  name = create :species_name, name: name_string
  citation = create :citation, pages: 'page 9'
  create :protonym, :species_group, name: name, authorship: citation, forms: 'dealate queen'
end
