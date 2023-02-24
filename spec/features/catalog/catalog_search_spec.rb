# frozen_string_literal: true

require 'rails_helper'

feature "Searching the catalog", as: :visitor do
  background do
    create :species, name_string: "Lasius niger"
    visit root_path
  end

  scenario "Searching for an exact match" do
    within "#desktop-only-header" do
      fill_in "qq", with: "Lasius niger"
    end
    find(:testid, 'header-catalog-search-button').click
    i_should_be_on 'the catalog page for "Lasius niger"'
    i_should_see "You were redirected to an exact match"
    i_should_see "Show more results"
  end
end
