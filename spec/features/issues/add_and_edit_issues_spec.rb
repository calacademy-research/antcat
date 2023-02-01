# frozen_string_literal: true

require 'rails_helper'

feature "Add and edit open issues", %(
  As an AntCat editor
  I want to add, edit and browse open issues
  So that editors can help each other to improve the catalog
) do
  background do
    i_log_in_as_a_catalog_editor_named "Archibald"
  end

  scenario "Adding an issue (with feed)" do
    i_go_to 'the open issues page'
    i_should_see "There are currently no open issues."

    i_follow "New"
    fill_in "issue_title", with: "Resolve homonyms"
    fill_in "issue_description", with: "Ids #999 and #777"
    fill_in "edit_summary", with: "added question"
    click_button "Save"
    i_should_see "Successfully created issue"

    i_go_to 'the open issues page'
    i_should_see "Resolve homonyms"

    there_should_be_an_activity "Archibald added the issue Resolve homonyms"
    i_should_see "added question"
  end

  scenario "Editing an issue (with feed)" do
    create :issue, :open, title: "Restore deleted species"

    i_go_to 'the open issues page'
    i_should_see "Restore deleted species"

    i_follow "Restore deleted species"
    i_follow "Edit"
    fill_in "issue_title", with: "Restore deleted genera"
    fill_in "issue_description", with: "The genera: #7554, #8863"
    fill_in "edit_summary", with: "added info"
    click_button "Save"
    i_should_see "Successfully updated issue"
    i_should_see "The genera: #7554, #8863"

    i_go_to 'the open issues page'
    i_should_see "Restore deleted genera"
    i_should_not_see "Restore deleted species"

    there_should_be_an_activity "Archibald edited the issue Restore deleted genera"
    i_should_see "added info"
  end

  scenario "Flagging an issue with 'Help wanted' and show notice in the nomen synopsis" do
    create :issue, :open, title: "Important fix"

    i_go_to 'the catalog'
    i_should_not_see "Help Wanted", within: 'the page header'

    i_go_to 'the open issues page'
    i_should_not_see "One or more open issues are tagged as 'Help wanted'"
    i_should_not_see "Important fix Help wanted!"

    i_follow "Important fix"
    i_follow "Edit"
    check "issue_help_wanted"
    click_button "Save"
    i_should_see "Successfully updated issue"

    i_go_to 'the catalog'
    i_should_see "Help Wanted", within: 'the page header'

    i_go_to 'the open issues page'
    i_should_see "One or more open issues are tagged as 'Help wanted'"
    i_should_see "Important fix Help wanted!"
  end

  scenario "Closing and re-opening an issue (with feed)" do
    create :issue, :open, title: "Add taxa from Aldous 2007"

    i_go_to 'the open issues page'
    i_follow "Add taxa from Aldous 2007"
    i_follow "Close"
    i_should_see "Successfully closed issue"
    i_should_see "Closed issue: Add taxa from Aldous 2007"

    there_should_be_an_activity "Archibald closed the issue Add taxa from Aldous 2007"

    i_go_to 'the open issues page'
    i_should_see "There are currently no open issues."

    i_follow_the_first "Add taxa from Aldous 2007"
    i_follow "Re-open"
    i_should_see "Successfully re-opened issue"
    i_should_see "Open issue: Add taxa from Aldous 2007"

    there_should_be_an_activity "Archibald re-opened the issue Add taxa from Aldous 2007"
  end
end
