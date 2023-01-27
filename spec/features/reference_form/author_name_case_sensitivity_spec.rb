# frozen_string_literal: true

require 'rails_helper'

feature "Author name case-sensitivity", %(
  As Marek
  I want to respect the case of an author's name in the source of a reference
  So that the bibliography is accurate
), as: :helper do
  scenario "Using the name that was entered" do
    create :any_reference, :with_author_name
    create :author_name, name: "Mackay"
    create :author_name, name: "MACKAY"
    create :author_name, name: "mackay"

    i_go_to 'the edit page for the most recent reference'
    fill_in "reference_author_names_string", with: "MACKAY"
    click_button "Save"
    i_should_see "MACKAY"

    i_go_to 'the edit page for the most recent reference'
    fill_in "reference_author_names_string", with: "mackay"
    click_button "Save"
    i_should_see "mackay"
  end
end
