# frozen_string_literal: true

def there_is_a_subfamily_protonym_with_a_history_item name, taxt
  protonym = create :protonym, :family_group, name: create(:subfamily_name, name: name)
  create :history_item, :taxt, taxt: taxt, protonym: protonym
end

def there_is_a_protonym_with_a_history_item_and_a_markdown_link_to name, content, key_with_year
  reference = ReferenceStepsHelpers.find_reference_by_key(key_with_year)
  taxt = "#{content} #{Taxt.ref(reference.id)}"
  there_is_a_subfamily_protonym_with_a_history_item name, taxt
end

# Editing.
def the_history_should_be content
  element = first('#history-items').find('.taxt-presenter')
  expect(element.text).to match(/#{content}/)
end

def the_history_item_field_should_be content
  element = first('#history-items').find('textarea')
  expect(element.text).to match(/#{content}/)
end

def the_history_item_field_should_not_be_visible
  expect(page).to_not have_css '#history-items textarea'
end

def the_history_item_field_should_be_visible
  expect(page).to have_css '#history-items textarea'
end

def the_history_should_be_empty
  expect(page).to_not have_css '#history-items .history-item'
end

def i_add_a_history_item content
  i_click_on 'the add history item button'
  fill_in "taxt", with: content
  click_button "Save"
end

# Relational history items.
def batiatus_2004a_has_described_the_forms_for_the_protonym pages, forms, protonym_name
  protonym = create :protonym, :species_group, name: create(:species_name, name: protonym_name)
  reference = create :any_reference, author_string: 'Batiatus', year: 2004, year_suffix: 'a'

  create :history_item, :form_descriptions, protonym: protonym,
    text_value: forms, reference: reference, pages: pages
end
