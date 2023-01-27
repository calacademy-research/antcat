# frozen_string_literal: true

def there_is_a_subfamily_with_a_reference_section name, references_taxt
  taxon = create :subfamily, name_string: name
  create :reference_section, references_taxt: references_taxt, taxon: taxon
end

# Editing.
def the_reference_section_should_be_empty
  expect(page).to_not have_css '#reference-sections .reference_section'
end

def the_reference_section_should_be content
  element = first('#references-section').find('.taxt-presenter')
  expect(element.text).to match(/#{content}/)
end
