# frozen_string_literal: true

require 'rails_helper'

feature "Author name case-sensitivity", as: :helper do
  scenario "Using the name that was entered" do
    reference = create :any_reference, :with_author_name
    create :author_name, name: "Mackay"
    create :author_name, name: "MACKAY"
    create :author_name, name: "mackay"

    visit edit_reference_path(reference)
    fill_in "reference_author_names_string", with: "MACKAY"
    click_button "Save"
    i_should_see "MACKAY"

    visit edit_reference_path(reference)
    fill_in "reference_author_names_string", with: "mackay"
    click_button "Save"
    i_should_see "mackay"
  end
end
