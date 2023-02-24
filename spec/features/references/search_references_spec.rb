# frozen_string_literal: true

require 'rails_helper'

feature "Searching references", as: :visitor do
  scenario "Searching for an author name with diacritics, using the diacritics in the query", :search do
    create :any_reference, author_string: "Hölldobler, B."
    create :any_reference, author_string: "Fisher, B."
    visit references_path

    find(:testid, 'header-reference-search-input').fill_in with: "Hölldobler"
    i_click_on 'the reference search button'
    i_should_see "Hölldobler, B."
    i_should_not_see "Fisher, B."
  end

  scenario "Finding nothing" do
    visit references_path

    find(:testid, 'header-reference-search-input').fill_in with: "zzzzzz"
    i_click_on 'the reference search button'
    i_should_see "No results found"
  end

  scenario "Maintaining search box contents" do
    visit references_path

    find(:testid, 'header-reference-search-input').fill_in with: "zzzzzz year:1972-1980"
    i_click_on 'the reference search button'
    i_should_see "No results found"
    expect(find(:testid, 'header-reference-search-input').value).to eq "zzzzzz year:1972-1980"
  end
end
