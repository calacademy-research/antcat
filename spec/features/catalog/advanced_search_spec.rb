# frozen_string_literal: true

require 'rails_helper'

feature "Searching the catalog" do
  background do
    i_go_to "the advanced search page"
  end

  scenario "Searching when no results" do
    i_fill_in "year", with: "2010"
    i_press "Search"
    i_should_see "No results"
  end

  scenario "Searching for subfamilies" do
    there_is_a_subfamily "Formicinae"

    i_select "Subfamily", from: "type"
    i_press "Search"
    i_should_see "1 result"
  end

  scenario "Searching for valid taxa" do
    there_is_an_invalid_family

    i_check "valid_only"
    i_press "Search"
    i_should_see "No results"
  end

  scenario "Searching for an author's descriptions" do
    there_is_a_species_described_by_bolton

    i_fill_in "author_name", with: "Bolton"
    i_press "Search"
    i_should_see "1 result"
  end

  scenario "Finding a genus" do
    there_is_a_species_in_the_genus "Atta major", "Atta"

    i_fill_in "genus", with: "Atta"
    i_press "Search"
    i_should_see "Atta major"
  end

  scenario "Searching for locality" do
    there_is_a_species_with_locality "Mexico"
    there_is_a_species_with_locality "Zimbabwe"

    i_fill_in "locality", with: "Mexico"
    i_press "Search"
    i_should_see "1 result"
    i_should_see "MEXICO", within: 'the search results'
  end

  scenario "Searching for bioregion" do
    there_is_a_species_with_bioregion "Malagasy"
    there_is_a_species_with_bioregion "Afrotropic"
    there_is_a_species_with_bioregion "Afrotropic"

    i_select "Afrotropic", from: "bioregion"
    i_press "Search"
    i_should_see "2 result(s)"
    i_should_see "Afrotropic", within: 'the search results'
  end

  scenario "Searching for 'None' bioregion" do
    there_is_a_species_with_bioregion "Malagasy"
    there_is_a_species_with_bioregion "Afrotropic"
    there_is_a_species_with_bioregion ""

    i_select "Species", from: "type"
    i_select "None", from: "bioregion"
    i_press "Search"
    i_should_see "1 result"
  end

  scenario "Searching in type fields" do
    there_is_a_species_with_primary_type_information "Madagascar: Prov. Toliara"

    i_fill_in "type_information", with: "Toliara"
    i_press "Search"
    i_should_see "1 result"
  end

  scenario "Searching for a form" do
    there_is_a_species_with_forms "w.q."
    there_is_a_species_with_forms "q."

    i_fill_in "forms", with: "w."
    i_press "Search"
    i_should_see "1 result"
    i_should_see "w.", within: 'the search results'
  end

  scenario "Searching for 'described in' (range)" do
    there_is_a_species_described_in 2010
    there_is_a_species_described_in 2011
    there_is_a_species_described_in 2012

    i_fill_in "year", with: "2010-2011"
    i_press "Search"
    i_should_see "2 result"
    i_should_see "2010", within: 'the search results'
    i_should_see "2011", within: 'the search results'
  end

  scenario "Download search results" do
    there_is_a_species_described_in 2010

    i_fill_in "year", with: "2010"
    i_press "Search"
    i_follow "Download"
    i_should_get_a_download_with_the_filename_and_todays_date "antcat_search_results__"
  end
end
