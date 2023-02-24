# frozen_string_literal: true

require 'rails_helper'

feature "Searching the catalog", as: :visitor do
  background do
    create :species, name_string: "Lasius niger"
    i_go_to 'the main page'
  end

  scenario "Searching when no results" do
    within "#desktop-only-header" do
      fill_in "qq", with: "zxxz"
    end
    i_click_on "the catalog search button"
    i_should_see "No results found"
  end

  scenario "Searching with results" do
    create :species, name_string: "Formica niger"

    within "#desktop-only-header" do
      fill_in "qq", with: "niger"
    end
    i_click_on "the catalog search button"
    i_should_see "Formica niger", within: "the search results"
    i_should_see "Lasius niger", within: "the search results"
  end

  scenario "Searching for an exact match" do
    within "#desktop-only-header" do
      fill_in "qq", with: "Lasius niger"
    end
    i_click_on "the catalog search button"
    i_should_be_on 'the catalog page for "Lasius niger"'
    i_should_see "You were redirected to an exact match"
    i_should_see "Show more results"
  end
end
