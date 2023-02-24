# frozen_string_literal: true

require 'rails_helper'

feature "Reference sections", as: :user do
  scenario "Filtering reference sections by search query" do
    create :reference_section, references_taxt: "typo of Forel"
    create :reference_section, references_taxt: "typo of August"

    visit reference_sections_path
    i_should_see "typo of Forel"
    i_should_see "typo of August"

    fill_in "q", with: "Forel"
    click_button "Search"
    i_should_see "typo of Forel"
    i_should_not_see "typo of August"

    fill_in "q", with: "asdasdasd"
    click_button "Search"
    i_should_not_see "typo of Forel"
    i_should_not_see "typo of August"
  end
end
