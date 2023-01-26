# frozen_string_literal: true

require 'rails_helper'

feature "Editing journals" do
  background do
    i_log_in_as_a_catalog_editor_named "Archibald"
    a_journal_exists_with_a_name_of "Psyche"
    i_go_to 'the references page'
    i_follow "Journals"
    i_follow "Psyche"
  end

  scenario "Edit a journal's name (with feed)" do
    i_follow "Edit journal name"
    i_fill_in "journal_name", with: "Science"
    i_press "Save"
    i_should_see "Successfully updated journal"

    i_go_to 'the references page'
    i_follow "Journals"
    i_should_see "Science"

    i_go_to 'the activity feed'
    i_should_see "Archibald edited the journal Science (changed journal name from Psyche)", within: 'the activity feed'
  end
end
