# frozen_string_literal: true

Given("there is a history item {string}") do |taxt|
  there_is_a_history_item taxt
end
def there_is_a_history_item taxt
  create :history_item, :taxt, taxt: taxt
end

Given("there is a subfamily protonym {string} with a history item {string}") do |name, taxt|
  there_is_a_subfamily_protonym_with_a_history_item name, taxt
end
def there_is_a_subfamily_protonym_with_a_history_item name, taxt
  protonym = create :protonym, :family_group, name: create(:subfamily_name, name: name)
  create :history_item, :taxt, taxt: taxt, protonym: protonym
end

Given(
  "there is a protonym {string} with a history item {string} and a markdown link to {string}"
) do |name, content, key_with_year|
  there_is_a_protonym_with_a_history_item_and_a_markdown_link_to name, content, key_with_year
end
def there_is_a_protonym_with_a_history_item_and_a_markdown_link_to name, content, key_with_year
  reference = ReferenceStepsHelpers.find_reference_by_key(key_with_year)
  taxt = "#{content} #{Taxt.ref(reference.id)}"
  there_is_a_subfamily_protonym_with_a_history_item name, taxt
end

# Editing.
Then("the history should be {string}") do |content|
  the_history_should_be content
end
def the_history_should_be content
  element = first('#history-items').find('.taxt-presenter')
  expect(element.text).to match(/#{content}/)
end

Then("the history item field should be {string}") do |content|
  the_history_item_field_should_be content
end
def the_history_item_field_should_be content
  element = first('#history-items').find('textarea')
  expect(element.text).to match(/#{content}/)
end

Then("the history item field should not be visible") do
  the_history_item_field_should_not_be_visible
end
def the_history_item_field_should_not_be_visible
  expect(page).to_not have_css '#history-items textarea'
end

Then("the history item field should be visible") do
  the_history_item_field_should_be_visible
end
def the_history_item_field_should_be_visible
  expect(page).to have_css '#history-items textarea'
end

Then("the history should be empty") do
  the_history_should_be_empty
end
def the_history_should_be_empty
  expect(page).to_not have_css '#history-items .history-item'
end

When("I add a history item {string}") do |content|
  i_add_a_history_item content
end
def i_add_a_history_item content
  i_click_on 'the add history item button'
  i_fill_in "taxt", with: content
  i_press "Save"
end

When("I update the most recent history item to say {string}") do |content|
  i_update_the_most_recent_history_item_to_say content
end
def i_update_the_most_recent_history_item_to_say content
  HistoryItem.last.update!(taxt: content)
end

When("I delete the most recent history item") do
  i_delete_the_most_recent_history_item
end
def i_delete_the_most_recent_history_item
  HistoryItem.last.destroy!
end

# Relational history items.
Given(
  "Batiatus, 2004a: {string} has described the forms {string} for the protonym {string}"
) do |pages, forms, protonym_name|
  batiatus_2004a_has_described_the_forms_for_the_protonym pages, forms, protonym_name
end
def batiatus_2004a_has_described_the_forms_for_the_protonym pages, forms, protonym_name
  protonym = create :protonym, :species_group, name: create(:species_name, name: protonym_name)
  reference = create :any_reference, author_string: 'Batiatus', year: 2004, year_suffix: 'a'

  create :history_item, :form_descriptions, protonym: protonym,
    text_value: forms, reference: reference, pages: pages
end
