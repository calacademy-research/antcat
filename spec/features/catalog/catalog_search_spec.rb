# frozen_string_literal: true

require 'rails_helper'

feature "Searching the catalog" do
  background do
    create :species, name_string: "Lasius niger"
    i_go_to 'the catalog'
  end

  scenario "Searching when no results" do
    i_fill_in "qq", with: "zxxz", within: "the desktop menu"
    i_click_on "the catalog search button"
    i_should_see "No results found"
  end

  scenario "Searching with results" do
    create :species, name_string: "Formica niger"

    i_fill_in "qq", with: "niger", within: "the desktop menu"
    i_click_on "the catalog search button"
    i_should_see "Formica niger", within: "the search results"
    i_should_see "Lasius niger", within: "the search results"
  end

  scenario "Searching for an exact match" do
    i_fill_in "qq", with: "Lasius niger", within: "the desktop menu"
    i_click_on "the catalog search button"
    i_should_be_on 'the catalog page for "Lasius niger"'
    i_should_see "You were redirected to an exact match"
    i_should_see "Show more results"
  end
end
