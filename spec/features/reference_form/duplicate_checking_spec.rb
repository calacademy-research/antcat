# frozen_string_literal: true

require 'rails_helper'

feature "Checking for duplicates during data entry", %(
  As an AntCat editor
  I want duplicate references to be rejected
  So that there are no duplicate references
) do
  background do
    i_log_in_as_a_helper_editor
    this_article_reference_exists author: "Ward, P.", title: "Ants", year: 2010, series_volume_issue: "4", pagination: "9"
  end

  scenario "Adding a duplicate reference, but saving it anyway" do
    i_go_to 'the references page'
    i_follow "New"
    i_fill_in "reference_author_names_string", with: "Ward, P."
    i_fill_in "reference_year", with: "2010"
    i_fill_in "reference_title", with: "Ants"
    i_fill_in "reference_journal_name", with: "Acta"
    i_fill_in "reference_series_volume_issue", with: "4"
    i_fill_in "reference_pagination", with: "9"
    i_press "Save"
    i_should_see "This may be a duplicate of Ward, 2010"

    i_press "Save"
    i_should_see "Reference was successfully added"
  end

  scenario "Editing a reference that makes it a duplicate" do
    there_is_an_article_reference

    i_go_to 'the edit page for the most recent reference'
    i_fill_in "reference_author_names_string", with: "Ward, P."
    i_fill_in "reference_title", with: "Ants"
    i_fill_in "reference_year", with: "2010"
    i_fill_in "reference_journal_name", with: "Acta"
    i_fill_in "reference_series_volume_issue", with: "4"
    i_press "Save"
    i_should_see "This may be a duplicate of Ward, 2010"

    i_press "Save"
    i_should_see "Reference was successfully updated"
  end
end
