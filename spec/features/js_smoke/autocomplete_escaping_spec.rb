# frozen_string_literal: true

require 'rails_helper'

# Autocomplete dropdowns must show stored text as text: markup in a title, author suffix
# or locality is displayed literally, never inserted into the page as HTML.
feature "Autocomplete dropdowns escape stored text", :js do
  let(:markup) { %(<img src="x" id="injected" onerror="window.__injected = true">) }

  before { install_js_error_collector }

  def expect_markup_shown_as_text_only
    expect(page).to have_no_css("#injected")
    expect(page.evaluate_script("window.__injected")).to be_nil
    expect_no_js_errors
  end

  feature "Visitor", as: :visitor do
    scenario "Header reference search shows the title and author suffix as text" do
      reference = create :any_reference, title: "Fourmis #{markup}", author_names_suffix: "<b id='injected'>(ed.)</b>"

      visit root_path
      wait_for_page_scripts

      # An exact reference ID match does not need Solr.
      find("[data-testid='header-reference-search-input'].tt-input").send_keys(reference.id.to_s)
      within "#desktop-only-header .tt-dataset-references" do
        expect(page).to have_css(".tt-suggestion", text: %(id="injected"))
        expect(page).to have_css(".tt-suggestion", text: "<b id='injected'>(ed.)</b>")
      end

      expect_markup_shown_as_text_only
    end
  end

  feature "Editor", as: :editor do
    scenario "Locality autocomplete shows the locality as text" do
      create :protonym, :species_group, locality: "Brazil #{markup}"
      protonym = create :protonym, :species_group

      visit edit_protonym_path(protonym)
      wait_for_page_scripts

      find("[data-use-locality-autocomplete].tt-input").send_keys("Brazil")
      expect(page).to have_css(".tt-dataset-localities .tt-suggestion", text: %(id="injected"))

      expect_markup_shown_as_text_only
    end

    scenario "Markdown reference autocompletion shows reference fields as text" do
      bolton_key = "Forel <i id='injected'>1878</i>"
      reference = create :any_reference, title: "Fourmis #{markup}", author_names_suffix: "<b id='injected'>(ed.)</b>", bolton_key: bolton_key

      visit new_issue_path
      wait_for_page_scripts
      wait_for_atwho_to_load

      # An exact reference ID match does not need Solr.
      find("#issue_description").send_keys("{r#{reference.id}")
      expect(page).to have_css(".atwho-view-ul li", text: %(id="injected"))
      expect(page).to have_css(".atwho-view-ul li", text: "<b id='injected'>(ed.)</b>")
      expect(page).to have_css(".atwho-view-ul li", text: "[Bolton key: Forel <i id='injected'>1878</i>]")

      expect_markup_shown_as_text_only
    end
  end
end
