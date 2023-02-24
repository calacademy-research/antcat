# frozen_string_literal: true

require 'rails_helper'

feature "Journals" do
  background do
    create :journal, name: "Psyche"
    visit references_path
    i_follow "Journals"
    i_follow "Psyche"
  end

  scenario "Edit a journal's name (with feed)", as: :editor do
    i_follow "Edit journal name"
    fill_in "journal_name", with: "Science"
    click_button "Save"
    i_should_see "Successfully updated journal"

    visit references_path
    i_follow "Journals"
    i_should_see "Science"

    there_should_be_an_activity "Archibald edited the journal Science \\(changed journal name from Psyche\\)"
  end
end
