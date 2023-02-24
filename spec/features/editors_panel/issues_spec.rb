# frozen_string_literal: true

require 'rails_helper'

feature "Issues" do
  background do
    i_log_in_as_a_catalog_editor_named "Archibald"
  end

  scenario "Adding an issue (with feed)" do
    visit issues_path
    i_should_see "There are currently no open issues."

    i_follow "New"
    fill_in "issue_title", with: "Resolve homonyms"
    fill_in "issue_description", with: "Ids #999 and #777"
    fill_in "edit_summary", with: "added question"
    click_button "Save"
    i_should_see "Successfully created issue"

    visit issues_path
    i_should_see "Resolve homonyms"

    there_should_be_an_activity "Archibald added the issue Resolve homonyms", edit_summary: "added question"
  end

  scenario "Editing an issue (with feed)" do
    create :issue, :open, title: "Restore deleted species"

    visit issues_path
    i_should_see "Restore deleted species"

    i_follow "Restore deleted species"
    i_follow "Edit"
    fill_in "issue_title", with: "Restore deleted genera"
    fill_in "issue_description", with: "The genera: #7554, #8863"
    fill_in "edit_summary", with: "added info"
    click_button "Save"
    i_should_see "Successfully updated issue"
    i_should_see "The genera: #7554, #8863"

    visit issues_path
    i_should_see "Restore deleted genera"
    i_should_not_see "Restore deleted species"

    there_should_be_an_activity "Archibald edited the issue Restore deleted genera", edit_summary: "added info"
  end

  scenario "Closing and re-opening an issue (with feed)" do
    create :issue, :open, title: "Add taxa from Aldous 2007"

    visit issues_path
    i_follow "Add taxa from Aldous 2007"
    i_follow "Close"
    i_should_see "Successfully closed issue"
    i_should_see "Closed issue: Add taxa from Aldous 2007"

    there_should_be_an_activity "Archibald closed the issue Add taxa from Aldous 2007"

    visit issues_path
    i_should_see "There are currently no open issues."

    i_follow_the_first "Add taxa from Aldous 2007"
    i_follow "Re-open"
    i_should_see "Successfully re-opened issue"
    i_should_see "Open issue: Add taxa from Aldous 2007"

    there_should_be_an_activity "Archibald re-opened the issue Add taxa from Aldous 2007"
  end
end
