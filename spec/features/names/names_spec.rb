# frozen_string_literal: true

require 'rails_helper'

feature "Names", as: :editor do
  scenario "Editing a name (with edit summary)" do
    protonym = create :protonym, :genus_group, protonym_name_string: "Formica"

    visit protonym_path(protonym)
    i_follow "Name record"
    i_should_see "Name record: Formica"

    i_follow "Edit"
    i_should_see "Formica"
    i_should_not_see "Similar names"
    i_should_not_see "Formicus"

    fill_in "name_name", with: "Lasius"
    fill_in "edit_summary", with: "fix name"
    click_button "Save"
    i_should_see "Successfully updated name."
    i_should_see "Name record: Lasius"

    there_should_be_an_activity "Archibald edited the name record Lasius", edit_summary: "fix name"
  end

  scenario "Checking for name conflicts", :skip_ci, :js do
    protonym = create :protonym, :genus_group, protonym_name_string: "Formica"
    create :protonym, :genus_group, protonym_name_string: "Formica"
    create :protonym, :genus_group, protonym_name_string: "Formicus"

    visit protonym_path(protonym)
    i_follow "Name record"
    i_follow "Edit"
    i_should_not_see "Similar names"
    i_should_not_see "Formica (protonym)"
    i_should_not_see "Formicus (protonym)"

    fill_in "name_name", with: "formi"
    i_should_see "Similar names"
    i_should_see "Formica (protonym)"
    i_should_see "Formicus (protonym)"

    fill_in "name_name", with: "formica"
    i_should_see "Homonym Formica (protonym)"
  end
end
