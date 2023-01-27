# frozen_string_literal: true

require 'rails_helper'

feature "Add and edit wiki pages" do
  background do
    i_log_in_as_a_catalog_editor_named "Archibald"
  end

  scenario "Adding a wiki page (with edit summary)" do
    i_go_to 'the wiki pages index'
    i_should_see "There are currently no wiki pages"

    i_follow "New"
    fill_in "wiki_page_title", with: "Bibliography guidelines"
    fill_in "wiki_page_content", with: "In the title, use capitals only"
    fill_in "edit_summary", with: "added help page"
    click_button "Save"
    i_should_see "Successfully created wiki page"

    i_go_to 'the wiki pages index'
    i_should_see "Bibliography guidelines"

    i_follow_the_first "Bibliography guidelines"
    i_should_see "In the title, use capitals only"

    i_go_to 'the activity feed'
    i_should_see "Archibald added the wiki page Bibliography guidelines", within: 'the activity feed'
    i_should_see_the_edit_summary "added help page"
  end

  scenario "Editing a wiki page (with edit summary)" do
    create :wiki_page, title: "Catalog guidelines"

    i_go_to 'the wiki pages index'
    i_follow_the_first "Catalog guidelines"
    i_follow "Edit"
    fill_in "wiki_page_title", with: "Name guidelines"
    fill_in "wiki_page_content", with: "Genus names must start with a capital letter"
    fill_in "edit_summary", with: "updated info"
    click_button "Save"
    i_should_see "Successfully updated wiki page"

    i_go_to 'the wiki pages index'
    i_should_see "Name guidelines"

    i_follow_the_first "Name guidelines"
    i_should_see "Genus names must start with a capital letter"

    i_go_to 'the activity feed'
    i_should_see "Archibald edited the wiki page Name guidelines", within: 'the activity feed'
    i_should_see_the_edit_summary "updated info"
  end
end
