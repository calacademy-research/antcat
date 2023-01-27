# frozen_string_literal: true

require 'rails_helper'

feature "Editing a history item" do
  def batiatus_2004a_has_described_the_forms_for_the_protonym pages, forms, protonym_name
    protonym = create :protonym, :species_group, name: create(:species_name, name: protonym_name)
    reference = create :any_reference, author_string: 'Batiatus', year: 2004, year_suffix: 'a'

    create :history_item, :form_descriptions, protonym: protonym,
      text_value: forms, reference: reference, pages: pages
  end

  background do
    i_log_in_as_a_catalog_editor_named "Archibald"
  end

  scenario "Adding a relational history item", :skip_ci, :js do
    there_is_a_genus_protonym "Atta"
    create :any_reference, author_string: "Batiatus", year: 2004

    i_go_to 'the protonym page for "Atta"'
    the_history_should_be_empty

    i_click_on 'the add history item button'
    select "Form descriptions (additional)", from: "history_item_type"
    fill_in "history_item_text_value", with: "w.q."
    fill_in "history_item_pages", with: "123"
    i_pick_from_the_reference_picker "Batiatus, 2004", "#history_item_reference_id"
    click_button "Save"
    i_should_see "Successfully added history item"
    i_should_see "Batiatus, 2004: 123 (w.q.)"
  end

  scenario "Adding a relational history item with errors" do
    there_is_a_genus_protonym "Atta"

    i_go_to 'the protonym page for "Atta"'
    the_history_should_be_empty

    i_click_on 'the add history item button'
    select "Form descriptions (additional)", from: "history_item_type"
    fill_in "taxt", with: "Pizza"

    click_button "Save"
    i_should_see "Taxt must be blank"
    i_should_see "Text value can't be blank"
    i_should_see "Reference can't be blank"
    i_should_see "Pages can't be blank"
  end

  # @retry_ci
  scenario "Editing a history item (via history item page)", :js do
    batiatus_2004a_has_described_the_forms_for_the_protonym "77-78", "q.", "Formica fusca"

    i_go_to 'the protonym page for "Formica fusca"'
    i_should_see "Batiatus, 2004a: 77-78 (q.)"

    i_go_to 'the page of the most recent history item'
    i_follow "Edit"
    fill_in "history_item_text_value", with: "w."
    fill_in "history_item_pages", with: "99"
    click_button "Save"
    i_should_see "Successfully updated history item"
    i_should_see "Batiatus, 2004a: 99 (w.)"
  end

  # @retry_ci
  scenario "Editing a history item (Quick edit)", :js do
    batiatus_2004a_has_described_the_forms_for_the_protonym "77-78", "q.", "Formica fusca"

    i_go_to 'the protonym page for "Formica fusca"'
    i_should_see "Batiatus, 2004a: 77-78 (q.)"

    i_click_on 'the edit history item button'
    fill_in "text_value", with: "w."
    fill_in "pages", with: "99"
    i_click_on 'the save history item button'
    i_reload_the_page
    i_should_see "Batiatus, 2004a: 99 (w.)"
  end
end
