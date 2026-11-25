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
    protonym = create :protonym, :species_group
    create :notes_page, protonym: protonym,
      content: "## Etymological notes\n\nA noun in apposition.\n\n> Spelling. The original spelling stands.\n\n| Year | Work |\n| --- | --- |\n| 1926 | Karavaiev |"
    taxon = create :species, protonym: protonym

    visit catalog_path(taxon)
    i_follow "[Etymological notes]"
    i_should_see "Notes on #{protonym.name.name}"
    within "[data-testid='notes-page-content']" do
      expect(page).to have_css "h2", text: "Etymological notes"
      expect(page).to have_css "blockquote", text: "Spelling. The original spelling stands."
      expect(page).to have_css "table td", text: "Karavaiev"
    end
  end

  scenario "The etymology and part of speech are shown under the protonym" do
    protonym = create :protonym, :species_group, gender_agreement_type: Protonym::NOUN_IN_APPOSITION,
      etymology_derivation: "From Greek <i>akantha</i> 'thorn'."
    taxon = create :species, protonym: protonym

    visit catalog_path(taxon)
    within "[data-testid='catalog-etymology']" do
      i_should_see "Etymology (AntCat):"
      expect(page).to have_css "i", text: "akantha"
      i_should_see "Part of speech: noun in apposition."
    end
  end

  scenario "The etymology and part-of-speech labels link to AntCat's policy pages, for any visitor" do
    create :wiki_page, title: "AntCat policy on derived etymologies", permanent_identifier: WikiPage::DERIVED_ETYMOLOGIES_POLICY
    create :wiki_page, title: "AntCat policy on name grammar and spelling", permanent_identifier: WikiPage::GRAMMAR_AND_SPELLING_POLICY
    protonym = create :protonym, :species_group, gender_agreement_type: Protonym::NOUN_IN_APPOSITION,
      etymology_derivation: "From Greek <i>akantha</i> 'thorn'."
    taxon = create :species, protonym: protonym

    visit catalog_path(taxon)
    within "[data-testid='catalog-etymology']" do
      i_should_see "Etymology (AntCat):"
      i_should_see "Part of speech: noun in apposition."
      i_follow "Etymology (AntCat)"
    end
    i_should_see "AntCat policy on derived etymologies"

    visit catalog_path(taxon)
    within "[data-testid='catalog-etymology']" do
      i_follow "Part of speech"
    end
    i_should_see "AntCat policy on name grammar and spelling"
  end

  scenario "An author's etymology is quoted with its source, and no AntCat derivation is shown beside it" do
    protonym = create :protonym, :species_group, etymology_taxt: "Named for the type locality.",
      etymology_source: 'original_description', etymology_pages: '12', etymology_derivation: "AntCat's own reading."
    taxon = create :species, protonym: protonym

    visit catalog_path(taxon)
    within "[data-testid='catalog-etymology']" do
      i_should_see "“Named for the type locality.”"
      i_should_see "original description"
      i_should_not_see "Etymology (AntCat):"
      i_should_not_see "AntCat's own reading."
    end
  end

  scenario "An author's etymology not in English is followed by AntCat's translation" do
    protonym = create :protonym, :species_group, etymology_taxt: "Nommé d'après la localité type.",
      etymology_source: 'original_description', etymology_pages: '12',
      etymology_translation: "From the French: Named for the type locality."
    taxon = create :species, protonym: protonym

    visit catalog_path(taxon)
    within "[data-testid='catalog-etymology']" do
      i_should_see "“Nommé d'après la localité type.”"
      i_should_see "Translation (AntCat): From the French: Named for the type locality."
    end
  end

  scenario "A name without etymology or part of speech has no etymology line" do
    taxon = create :species

    visit catalog_path(taxon)
    i_should_see taxon.name.name
    expect(page).to have_no_css "[data-testid='catalog-etymology']"
  end

  scenario "A name without notes shows no link to them" do
    taxon = create :species

    visit catalog_path(taxon)
    i_should_see taxon.name.name
    expect(page).to have_no_link href: protonym_notes_path(taxon.protonym)
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
