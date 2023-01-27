# frozen_string_literal: true

require 'rails_helper'

feature "Manage names" do
  background do
    i_log_in_as_a_catalog_editor_named "Archibald"
  end

  scenario "Editing a name (with edit summary)" do
    there_is_a_genus_protonym "Formica"

    i_go_to 'the protonym page for "Formica"'
    i_follow "Name record"
    i_should_see "Name record: Formica"

    i_follow "Edit"
    i_should_see "Formica"
    i_should_not_see "Similar names"
    i_should_not_see "Formicus"

    fill_in "name_name_string", with: "Lasius"
    fill_in "edit_summary", with: "fix name"
    click_button "Save"
    i_should_see "Successfully updated name."
    i_should_see "Name record: Lasius"

    i_go_to 'the activity feed'
    i_should_see "Archibald edited the name record Lasius", within: 'the activity feed'
    i_should_see_the_edit_summary "fix name"
  end

  scenario "Checking for name conflicts", :skip_ci, :js do
    there_is_a_genus_protonym "Formica"
    there_is_a_genus_protonym "Formica"
    there_is_a_genus_protonym "Formicus"

    i_go_to 'the protonym page for "Formica"'
    i_follow "Name record"
    i_follow "Edit"
    i_should_not_see "Similar names"
    i_should_not_see "Formica (protonym)"
    i_should_not_see "Formicus (protonym)"

    fill_in "name_name_string", with: "formi"
    i_should_see "Similar names"
    i_should_see "Formica (protonym)"
    i_should_see "Formicus (protonym)"

    fill_in "name_name_string", with: "formica"
    i_should_see "Homonym Formica (protonym)"
  end
end
