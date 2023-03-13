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

  feature "Editing history items", as: :editor do
    scenario "Adding a history item (with edit summary)" do
      protonym = create :protonym, :genus_group, protonym_name_string: "Atta"

      visit protonym_path(protonym)
      the_history_should_be_empty

      find(:testid, 'add-history-item-button').click
      fill_in "taxt", with: "Abc"
      fill_in "edit_summary", with: "added new stuff"
      expect { click_button "Save" }.to change { HistoryItem.count }.by(1)
      the_history_should_be "Abc"

      there_should_be_an_activity "Archibald added the history item ##{HistoryItem.last.id} belonging to Atta", edit_summary: "added new stuff"
    end

    scenario "Adding a history item with blank taxt" do
      protonym = create :protonym

      visit protonym_path(protonym)
      the_history_should_be_empty

      find(:testid, 'add-history-item-button').click
      click_button "Save"
      i_should_see "Taxt can't be blank"
    end

    scenario "Editing a history item (with edit summary)", :js do
      protonym = create :protonym, :family_group_subfamily_name, protonym_name_string: "Antcatinae"
      history_item = create :history_item, :taxt, taxt: "Antcatinae as family", protonym: protonym

      visit protonym_path(protonym)
      the_history_should_be "Antcatinae as family"

      wait_for_taxt_editors_to_load
      find(:testid, 'history-item-taxt-editor-edit-button').click
      fill_in "taxt", with: "(none)"
      within "#history-items" do
        fill_in "edit_summary", with: "fix typo"
      end
      find(:testid, 'history-item-taxt-editor-save-button').click
      i_reload_the_page
      i_should_not_see "Antcatinae as family"
      the_history_should_be "(none)"

      wait_for_taxt_editors_to_load
      find(:testid, 'history-item-taxt-editor-edit-button').click
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
      find(:testid, 'history-item-taxt-editor-edit-button').click
      fill_in "taxt", with: "(none)"
      find(:testid, 'history-item-taxt-editor-cancel-button').click
      the_history_should_be "Antcatinae as family"

      find(:testid, 'history-item-taxt-editor-edit-button').click
      the_history_item_field_should_be "Antcatinae as family"
    end

    scenario "Deleting a history item (with feed)", :js do
      protonym = create :protonym, :family_group_subfamily_name, protonym_name_string: "Antcatinae"
      history_item = create :history_item, :taxt, taxt: "Antcatinae as family", protonym: protonym

      visit protonym_path(protonym)
      i_should_see "Antcatinae as family"

      wait_for_taxt_editors_to_load
      find(:testid, 'history-item-taxt-editor-edit-button').click
      fill_in "edit_summary", with: "delete duplicate"
      i_will_confirm_on_the_next_step
      expect { find(:testid, 'history-item-taxt-editor-delete-button').click }.to change { HistoryItem.count }.by(-1)
      i_should_be_on protonym_path(protonym)

      i_reload_the_page
      the_history_should_be_empty

      there_should_be_an_activity "Archibald deleted the history item ##{history_item.id} belonging to Antcatinae",
        edit_summary: "delete duplicate"
    end
  end
end
