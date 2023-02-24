# frozen_string_literal: true

require 'rails_helper'

feature "History items" do
  feature "Browse history items", as: :user do
    scenario "Filtering history items by search query" do
      create :history_item, :taxt, taxt: "typo of Forel"
      create :history_item, :taxt, taxt: "typo of August"

      visit history_items_path
      i_should_see "typo of Forel"
      i_should_see "typo of August"

      fill_in "q", with: "Forel"
      click_button "Search"
      i_should_see "typo of Forel"
      i_should_not_see "typo of August"

      fill_in "q", with: "asdasdasd"
      click_button "Search"
      i_should_not_see "typo of Forel"
      i_should_not_see "typo of August"
    end
  end

  feature "Editing history items" do
    background do
      i_log_in_as_a_catalog_editor_named "Archibald"
    end

    scenario "Adding a history item (with edit summary)" do
      protonym = create :protonym, :genus_group, name: create(:genus_name, name: "Atta")

      visit protonym_path(protonym)
      the_history_should_be_empty

      i_click_on 'the add history item button'
      fill_in "taxt", with: "Abc"
      fill_in "edit_summary", with: "added new stuff"
      click_button "Save"
      the_history_should_be "Abc"

      there_should_be_an_activity "Archibald added the history item ##{HistoryItem.last.id} belonging to Atta", edit_summary: "added new stuff"
    end

    scenario "Adding a history item with blank taxt" do
      protonym = create :protonym

      visit protonym_path(protonym)
      the_history_should_be_empty

      i_click_on 'the add history item button'
      click_button "Save"
      i_should_see "Taxt can't be blank"
    end

    scenario "Editing a history item (with edit summary)", :js do
      protonym = create :protonym, :family_group, name: create(:subfamily_name, name: "Antcatinae")
      history_item = create :history_item, :taxt, taxt: "Antcatinae as family", protonym: protonym

      visit protonym_path(protonym)
      the_history_should_be "Antcatinae as family"

      wait_for_taxt_editors_to_load
      i_click_on 'the edit history item button'
      fill_in "taxt", with: "(none)"
      within "#history-items" do
        fill_in "edit_summary", with: "fix typo"
      end
      i_click_on 'the save history item button'
      i_reload_the_page
      i_should_not_see "Antcatinae as family"
      the_history_should_be "(none)"

      wait_for_taxt_editors_to_load
      i_click_on 'the edit history item button'
      the_history_item_field_should_be "(none)"

      there_should_be_an_activity "Archibald edited the history item ##{history_item.id} belonging to Antcatinae", edit_summary: "fix typo"
    end

    scenario "Editing a history item (without JavaScript)" do
      history_item = create :history_item, :taxt, taxt: "Antcatinae as family"

      visit history_item_path(history_item)
      i_follow "Edit"
      i_should_see "Antcatinae as family"

      fill_in "taxt", with: "history item content"
      click_button "Save"
      i_should_see "Successfully updated history item #"
      i_should_see "history item content"
    end

    scenario "Editing a history item, but cancelling", :js do
      protonym = create :protonym
      create :history_item, :taxt, taxt: "Antcatinae as family", protonym: protonym

      visit protonym_path(protonym)
      wait_for_taxt_editors_to_load
      i_click_on 'the edit history item button'
      fill_in "taxt", with: "(none)"
      i_click_on 'the cancel history item button'
      the_history_should_be "Antcatinae as family"

      i_click_on 'the edit history item button'
      the_history_item_field_should_be "Antcatinae as family"
    end

    scenario "Deleting a history item (with feed)", :js do
      protonym = create :protonym, :family_group, name: create(:subfamily_name, name: "Antcatinae")
      history_item = create :history_item, :taxt, taxt: "Antcatinae as family", protonym: protonym

      visit protonym_path(protonym)
      i_should_see "Antcatinae as family"

      wait_for_taxt_editors_to_load
      i_click_on 'the edit history item button'
      i_will_confirm_on_the_next_step
      i_click_on 'the delete history item button'
      i_should_be_on 'the protonym page for "Antcatinae"'

      i_reload_the_page
      the_history_should_be_empty

      there_should_be_an_activity "Archibald deleted the history item ##{history_item.id} belonging to Antcatinae"
    end
  end
end
