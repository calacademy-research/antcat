# frozen_string_literal: true

require 'rails_helper'

feature "Institutions" do
  scenario "Adding an institution (with edit summary)" do
    i_log_in_as_a_catalog_editor_named "Archibald"

    i_go_to "the Editor's Panel"
    i_follow "Edit institutions"
    i_should_not_see "CASC"
    i_should_not_see "California Academy of Sciences"

    i_follow "New"
    fill_in "institution_abbreviation", with: "CASC"
    fill_in "institution_name", with: "California Academy of Sciences"
    fill_in "edit_summary", with: "fix typo"
    click_button "Save"
    i_should_see "Successfully created institution"

    i_go_to 'the institutions page'
    i_should_see "CASC"
    i_should_see "California Academy of Sciences"

    i_go_to 'the activity feed'
    i_should_see "Archibald added the institution CASC", within: 'the activity feed'
    i_should_see_the_edit_summary "fix typo"
  end

  scenario "Editing an institution (with edit summary)" do
    create :institution, abbreviation: "CASC", name: "California Academy of Sciences"
    i_log_in_as_a_catalog_editor_named "Archibald"

    i_go_to 'the institutions page'
    i_follow_the_first "California Academy of Sciences"
    i_follow "Edit"
    fill_in "institution_abbreviation", with: "SASC"
    fill_in "institution_name", with: "Sweden Academy of Sciences"
    fill_in "edit_summary", with: "fix typo"
    click_button "Save"
    i_should_see "Successfully updated institution"

    i_go_to 'the institutions page'
    i_should_see "SASC"
    i_should_see "Sweden Academy of Sciences"

    i_go_to 'the activity feed'
    i_should_see "Archibald edited the institution SASC", within: 'the activity feed'
    i_should_see_the_edit_summary "fix typo"
  end

  scenario "Deleting an institution (with feed)" do
    create :institution, abbreviation: "CASC", name: "California Academy of Sciences"
    i_log_in_as_a_superadmin_named "Archibald"

    i_go_to 'the institutions page'
    i_follow_the_first "California Academy of Sciences"
    i_follow "Delete"
    i_should_be_on 'the institutions page'
    i_should_see "Institution was successfully deleted"
    i_should_not_see "CASC"

    i_go_to 'the activity feed'
    i_should_see "Archibald deleted the institution CASC", within: 'the activity feed'
  end
end
