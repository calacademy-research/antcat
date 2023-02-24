# frozen_string_literal: true

require 'rails_helper'

feature "Checking for duplicates during data entry", as: :helper do
  background do
    create :article_reference, author_string: "Ward, P.", title: "Ants", year: 2010, series_volume_issue: "4", pagination: "9"
  end

  scenario "Adding a duplicate reference, but saving it anyway" do
    i_go_to 'the references page'
    i_follow "New"
    fill_in "reference_author_names_string", with: "Ward, P."
    fill_in "reference_year", with: "2010"
    fill_in "reference_title", with: "Ants"
    fill_in "reference_journal_name", with: "Acta"
    fill_in "reference_series_volume_issue", with: "4"
    fill_in "reference_pagination", with: "9"
    click_button "Save"
    i_should_see "This may be a duplicate of Ward, 2010"

    click_button "Save"
    i_should_see "Reference was successfully added"
  end

  scenario "Editing a reference that makes it a duplicate" do
    reference = create :article_reference, :with_author_name

    visit edit_reference_path(reference)
    fill_in "reference_author_names_string", with: "Ward, P."
    fill_in "reference_title", with: "Ants"
    fill_in "reference_year", with: "2010"
    fill_in "reference_journal_name", with: "Acta"
    fill_in "reference_series_volume_issue", with: "4"
    click_button "Save"
    i_should_see "This may be a duplicate of Ward, 2010"

    click_button "Save"
    i_should_see "Reference was successfully updated"
  end
end
