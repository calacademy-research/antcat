# frozen_string_literal: true

require 'rails_helper'

feature "Using the catalog" do
  background do
    the_formicidae_family_exists
    create :subfamily, name_string: "Dolichoderinae"
    there_is_a_tribe_in_the_subfamily "Dolichoderini", "Dolichoderinae"
    there_is_a_genus_in_the_tribe "Dolichoderus", "Dolichoderini"
    there_is_a_species_in_the_genus "Dolichoderus abruptus", "Dolichoderus"
    there_is_a_subspecies_in_the_species "Dolichoderus abruptus minor", "Dolichoderus abruptus"
    i_go_to 'the catalog'
  end

  scenario "Going to the main page" do
    i_should_see "Formicidae"
    i_should_see "Subfamilies of Formicidae: Dolichoderinae"
  end

  scenario "Selecting a subfamily" do
    i_follow "Dolichoderinae", within: 'the taxon browser'
    should_be_selected_in_the_taxon_browser "Dolichoderinae"
  end

  scenario "Selecting a tribe" do
    i_follow "Dolichoderinae", within: 'the taxon browser'
    i_follow "Dolichoderini", within: 'the taxon browser'
    should_be_selected_in_the_taxon_browser "Dolichoderinae"
    should_be_selected_in_the_taxon_browser "Dolichoderini"
    i_should_see "Dolichoderus", within: 'the taxon browser'
  end

  scenario "Selecting a genus" do
    i_follow "Dolichoderinae", within: 'the taxon browser'
    i_select_the_taxon_browser_tab ".taxon-browser-tab-0"
    i_follow "Dolichoderus"
    should_be_selected_in_the_taxon_browser "Dolichoderinae"
    should_be_selected_in_the_taxon_browser "Dolichoderus"
    i_should_see "abruptus", within: 'the taxon browser'
  end

  scenario "Selecting a species" do
    i_follow "Dolichoderinae", within: 'the taxon browser'
    i_select_the_taxon_browser_tab ".taxon-browser-tab-1"
    i_follow "Dolichoderus"
    i_follow "abruptus"
    should_be_selected_in_the_taxon_browser "Dolichoderinae"
    should_be_selected_in_the_taxon_browser "Dolichoderus"
    should_be_selected_in_the_taxon_browser "abruptus"
  end

  scenario "Selecting a subspecies" do
    i_follow "Dolichoderinae", within: 'the taxon browser'
    i_select_the_taxon_browser_tab ".taxon-browser-tab-1"
    i_follow "Dolichoderus"
    i_should_see "abruptus", within: 'the taxon browser'

    i_follow "abruptus"
    i_should_see "minor", within: 'the taxon browser'
  end
end
