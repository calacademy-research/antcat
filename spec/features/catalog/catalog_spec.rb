# frozen_string_literal: true

require 'rails_helper'

feature "Using the catalog", as: :visitor do
  def should_be_selected_in_the_taxon_browser name
    within '#taxon-browser' do
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
    create :genus, :without_tribe, name_string: "Dolichoderus", subfamily: tribe.subfamily, tribe: tribe

    visit root_path
  end

  scenario "Selecting a subfamily" do
    i_follow "Dolichoderinae", within: 'the taxon browser'
    should_be_selected_in_the_taxon_browser "Dolichoderinae"
  end

  scenario "Selecting a genus" do
    i_follow "Dolichoderinae", within: 'the taxon browser'
    i_select_the_taxon_browser_tab ".taxon-browser-tab-0"
    i_follow "Dolichoderus"
    should_be_selected_in_the_taxon_browser "Dolichoderinae"
    should_be_selected_in_the_taxon_browser "Dolichoderini"
    should_be_selected_in_the_taxon_browser "Dolichoderus"
  end
end
