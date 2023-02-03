# frozen_string_literal: true

require 'rails_helper'

feature "Using the catalog" do
  def should_be_selected_in_the_taxon_browser name
    within '#taxon-browser-new' do
      expect(page).to have_css ".selected", text: name
    end
  end

  # TODO: Remove hack with 'i_select_the_taxon_browser_tab ".taxon-browser-tab-0"'.
  def i_select_the_taxon_browser_tab tab_css_selector
    find(tab_css_selector, visible: false).click
  end

  background do
    create :family, :formicidae
    subfamily = create :subfamily, name_string: "Dolichoderinae"
    tribe = create :tribe, name_string: "Dolichoderini", subfamily: subfamily
    genus = create :genus, name_string: "Dolichoderus", subfamily: tribe.subfamily, tribe: tribe
    species = create :species, name_string: "Dolichoderus abruptus", genus: genus
    create :subspecies, name_string: "Dolichoderus abruptus minor", species: species, genus: species.genus

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
