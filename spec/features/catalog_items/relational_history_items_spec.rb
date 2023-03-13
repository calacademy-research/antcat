# frozen_string_literal: true

require 'rails_helper'

feature "Editing relational history items", as: :editor do
  scenario "Adding a relational history item", :js do
    protonym = create :protonym, :genus_group
    create :any_reference, author_string: "Batiatus", year: 2004

    visit protonym_path(protonym)
    the_history_should_be_empty

    find(:testid, 'add-history-item-button').click
    wait_for_taxt_editors_to_load
    select "Form descriptions (additional)", from: "history_item_type"
    fill_in "history_item_text_value", with: "w.q."
    fill_in "history_item_pages", with: "123"
    i_pick_from_the_reference_picker "Batiatus, 2004", "#history_item_reference_id"
    expect { click_button "Save" }.to change { HistoryItem.count }.by(1)
    i_should_see "Successfully added history item"
    i_should_see "Batiatus, 2004: 123 (w.q.)"
  end

  scenario "Adding a relational history item with errors" do
    protonym = create :protonym

    visit protonym_path(protonym)
    the_history_should_be_empty

    find(:testid, 'add-history-item-button').click
    select "Form descriptions (additional)", from: "history_item_type"
    fill_in "taxt", with: "Pizza"

    click_button "Save"
    i_should_see "Taxt must be blank"
    i_should_see "Text value can't be blank"
    i_should_see "Reference can't be blank"
    i_should_see "Pages can't be blank"
  end

  scenario "Editing a history item (via history item page)", :js do
    protonym = create :protonym, :species_group
    reference = create :any_reference, author_string: 'Batiatus', year: 2004, year_suffix: 'a'
    create :history_item, :form_descriptions, protonym: protonym, text_value: "q.", reference: reference, pages: "77-78"

    visit protonym_path(protonym)
    i_should_see "Batiatus, 2004a: 77-78 (q.)"

    visit history_item_path(HistoryItem.last)
    i_follow "Edit"
    wait_for_taxt_editors_to_load
    fill_in "history_item_text_value", with: "w."
    fill_in "history_item_pages", with: "99"
    click_button "Save"
    i_should_see "Successfully updated history item"
    i_should_see "Batiatus, 2004a: 99 (w.)"
  end

  scenario "Editing a history item (Quick edit)", :js do
    protonym = create :protonym, :species_group
    reference = create :any_reference, author_string: 'Batiatus', year: 2004, year_suffix: 'a'
    create :history_item, :form_descriptions, protonym: protonym, text_value: "q.", reference: reference, pages: "77-78"

    visit protonym_path(protonym)
    i_should_see "Batiatus, 2004a: 77-78 (q.)"

    wait_for_taxt_editors_to_load
    find(:testid, 'history-item-taxt-editor-edit-button').click
    fill_in "text_value", with: "w."
    fill_in "pages", with: "99"
    find(:testid, 'history-item-taxt-editor-save-button').click
    i_reload_the_page
    i_should_see "Batiatus, 2004a: 99 (w.)"
  end
end
