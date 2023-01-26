# frozen_string_literal: true

require 'rails_helper'

feature "Author name case-sensitivity", %(
  As Marek
  I want to respect the case of an author's name in the source of a reference
  So that the bibliography is accurate
) do
  scenario "Using the name that was entered" do
    i_log_in_as_a_helper_editor
    there_is_a_reference
    an_author_name_exists_with_a_name_of "Mackay"
    an_author_name_exists_with_a_name_of "MACKAY"
    an_author_name_exists_with_a_name_of "mackay"

    i_go_to 'the edit page for the most recent reference'
    i_fill_in "reference_author_names_string", with: "MACKAY"
    i_press "Save"
    i_should_see "MACKAY"

    i_go_to 'the edit page for the most recent reference'
    i_fill_in "reference_author_names_string", with: "mackay"
    i_press "Save"
    i_should_see "mackay"
  end
end
