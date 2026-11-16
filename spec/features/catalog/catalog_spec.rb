# frozen_string_literal: true

require 'rails_helper'

feature "Using the catalog", as: :visitor do
  def should_be_selected_in_the_taxon_browser name
    within '#taxon-browser' do
      expect(page).to have_css ".selected", text: name
    end
  end

  # TODO: Remove hack with 'i_select_the_taxon_browser_tab "#taxon-browser-tab-0"'.
  def i_select_the_taxon_browser_tab tab_css_selector
    find(tab_css_selector, visible: false).click
  end

  scenario "Following the notes on a name from its catalog page" do
    wiki_page = create :wiki_page, title: "Notes: Leptothorax nylanderi var. crassispina", content: "Etymological notes"
    protonym = create :protonym, :species_group, grammar_and_spelling_wiki_page: wiki_page
    taxon = create :species, protonym: protonym

    visit catalog_path(taxon)
    i_follow "[notes on this name]"
    i_should_see "Etymological notes"
    i_should_see "Notes on: #{protonym.name.name}"
  end

  scenario "A name without a page of notes shows no link to one" do
    taxon = create :species

    visit catalog_path(taxon)
    i_should_not_see "[notes on this name]"
  end

  scenario "Selecting a subfamily" do
    create :subfamily, :with_family, name_string: "Dolichoderinae"
    visit root_path

    i_follow "Dolichoderinae", within_scope: "#taxon-browser"
    should_be_selected_in_the_taxon_browser "Dolichoderinae"
  end

  scenario "Selecting a genus" do
    subfamily = create :subfamily, :with_family, name_string: "Dolichoderinae"
    tribe = create :tribe, name_string: "Dolichoderini", subfamily: subfamily
    create :genus, :without_tribe, name_string: "Dolichoderus", subfamily: tribe.subfamily, tribe: tribe

    visit root_path

    i_follow "Dolichoderinae", within_scope: "#taxon-browser"
    i_select_the_taxon_browser_tab "#taxon-browser-tab-0"
    i_follow "Dolichoderus"
    should_be_selected_in_the_taxon_browser "Dolichoderinae"
    should_be_selected_in_the_taxon_browser "Dolichoderini"
    should_be_selected_in_the_taxon_browser "Dolichoderus"
  end

  scenario "Showing/hiding invalid taxa" do
    create :family, :formicidae
    create :subfamily, name_string: "Availableinae"
    create :subfamily, :unidentifiable, name_string: "Invalidinae"

    visit root_path
    i_should_see "Availableinae"
    i_should_not_see "Invalidinae"

    i_follow "show invalid"
    i_should_see "Invalidinae"
    i_should_see "Availableinae"

    i_follow "show valid only"
    i_should_see "Availableinae"
    i_should_not_see "Invalidinae"
  end
end
