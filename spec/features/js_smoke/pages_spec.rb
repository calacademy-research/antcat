# frozen_string_literal: true

require 'rails_helper'

# Browser smoke tests: load the main page types in headless Chrome and fail on any uncaught JavaScript
# error, and exercise the JavaScript widgets that every visitor or editor depends on (header quick
# search, advanced search autocomplete, record pickers, markdown preview).
#
# Background: on AntWeb a jQuery upgrade silently broke the header search autocomplete because no
# spec ran pages in a real browser. See `spec/support/javascript_errors.rb`.

# Page name => [path (evaluated in the example), text or title the page must show].
visitor_pages = {
  "catalog root" => [-> { root_path }, { text: "Dolichoderinae" }],
  "taxon page" => [-> { catalog_path(genus) }, { text: "Revived from synonymy" }],
  "protonym page" => [-> { protonym_path(genus.protonym) }, { text: "Taxa belonging to this protonym" }],
  "reference page" => [-> { reference_path(reference) }, { text: "Fourmis de la Suisse" }],
  "author page" => [-> { author_path(reference.author_names.first.author) }, { text: "Forel, A." }],
  "journal page" => [-> { journal_path(reference.journal) }, { text: "Mitteilungen der Schweizerischen" }],
  "catalog search form" => [-> { catalog_search_path }, { title: "Advanced Search - AntCat" }],
  "wiki pages index" => [-> { wiki_pages_path }, { text: "Ant identification wiki" }],
  "issues index" => [-> { issues_path }, { text: "Missing type locality" }]
}
editor_pages = visitor_pages.merge(
  "editors panel" => [-> { editors_panel_path }, { title: "Editor's Panel - AntCat" }],
  "taxon edit form" => [-> { edit_taxon_path(genus) }, { text: "Status-specific fields" }],
  "new reference form" => [-> { new_reference_path }, { css: "#reference_author_names_string" }]
)

feature "JavaScript smoke tests", :js do
  let!(:reference) do
    journal = create :journal, name: "Mitteilungen der Schweizerischen Entomologischen Gesellschaft"
    create :any_reference, author_string: "Forel, A.", year: 1878, title: "Fourmis de la Suisse", journal: journal
  end
  let!(:genus) do
    subfamily = create :subfamily, name_string: "Dolichoderinae"
    protonym = create :protonym, :genus_group, protonym_name_string: "Dolichoderus", authorship_reference: reference
    create :genus, :without_tribe, name_string: "Dolichoderus", subfamily: subfamily, protonym: protonym
  end
  let!(:species) { create :species, name_string: "Dolichoderus taschenbergi", genus: genus }

  before do
    create :family, :formicidae
    create :history_item, :taxt, protonym: genus.protonym, taxt: "Revived from synonymy: #{Taxt.ref(reference.id)}"
    create :history_item, :junior_synonym_of, protonym: genus.protonym
    create :reference_section, taxon: genus, references_taxt: "Catalog: #{Taxt.ref(reference.id)}"
    create :wiki_page, title: "Ant identification wiki"
    create :issue, :open, title: "Missing type locality"

    install_js_error_collector
  end

  def visit_and_check_page path, expected
    visit path
    wait_for_page_scripts
    expect(page).to have_text(expected[:text]) if expected[:text]
    expect(page).to have_title(expected[:title]) if expected[:title]
    expect(page).to have_css(expected[:css]) if expected[:css]
    expect_no_js_errors
  end

  feature "Visitor", as: :visitor do
    visitor_pages.each do |page_name, (path, expected)|
      scenario "#{page_name} has no JavaScript errors" do
        visit_and_check_page instance_exec(&path), expected
      end
    end

    scenario "Header quick search suggests taxa and authors", :search do
      Sunspot.commit
      visit_and_check_page catalog_path(species), text: "Dolichoderus taschenbergi"

      find("#desktop-only-header input.typeahead-taxa-js-hook.tt-input").send_keys("Dolichoderu")
      within "#desktop-only-header .tt-dataset-taxa" do
        expect(page).to have_css(".tt-suggestion", text: "Dolichoderus")
      end

      find("[data-testid='header-reference-search-input'].tt-input").send_keys("Fore")
      within "#desktop-only-header .tt-dataset-authors" do
        expect(page).to have_css(".tt-suggestion", text: "Forel, A.")
      end

      expect_no_js_errors
    end

    scenario "Selecting a header quick search suggestion opens the taxon", :search do
      Sunspot.commit
      visit_and_check_page root_path, text: "Dolichoderinae"

      find("#desktop-only-header input.typeahead-taxa-js-hook.tt-input").send_keys("taschenb")
      find("#desktop-only-header .tt-dataset-taxa .tt-suggestion", text: "Dolichoderus taschenbergi").click

      expect(page).to have_current_path(catalog_path(species), ignore_query: true)
      wait_for_page_scripts
      expect_no_js_errors
    end

    scenario "References search results", :search do
      Sunspot.commit
      visit_and_check_page references_search_index_path(reference_q: "Fourmis"), text: "Fourmis de la Suisse"
    end

    scenario "Advanced search author autocomplete" do
      visit_and_check_page catalog_search_path, title: "Advanced Search - AntCat"

      find_field("author_name").send_keys("Fore")
      find(".ui-autocomplete .ui-menu-item", text: "Forel, A.").click
      expect(find_field("author_name").value).to eq "Forel, A."

      click_button "Search"
      within("table") { expect(page).to have_link("Dolichoderus") }
      wait_for_page_scripts
      expect_no_js_errors
    end

    feature "Phone-width screen (390x844)" do
      before { page.current_window.resize_to(390, 844) }
      after { page.current_window.resize_to(1200, 800) }

      scenario "catalog root" do
        visit_and_check_page root_path, text: "Dolichoderinae"
        expect(page).to have_css("#mobile-only-header")
        expect(page).to have_no_css("#desktop-only-header")
      end

      scenario "taxon page" do
        visit_and_check_page catalog_path(genus), text: "Revived from synonymy"
        expect(page).to have_css("#mobile-only-header")
        expect(page).to have_no_css("#desktop-only-header")
      end
    end
  end

  feature "Editor", as: :editor do
    editor_pages.each do |page_name, (path, expected)|
      scenario "#{page_name} has no JavaScript errors" do
        visit_and_check_page instance_exec(&path), expected
      end
    end

    scenario "Taxon picker in the taxon edit form" do
      visit_and_check_page edit_taxon_path(genus), text: "Status-specific fields"

      picker = find("#taxon_current_taxon_id", visible: :all).ancestor("[data-controller='picker']")
      within picker do
        click_button "Pick"
        find("[data-picker-target='searchInput']").send_keys(species.id.to_s) # Exact ID matches do not need Solr.
        # Click the record ID; the name in the row is a link to the catalog page.
        find(".pickable-row", text: "Dolichoderus taschenbergi").find(".pickable-record-id").click
        expect(find("[data-picker-target='fakeInput']")).to have_text("Dolichoderus taschenbergi")
      end
      expect(find("#taxon_current_taxon_id", visible: :all).value).to eq species.id.to_s

      expect_no_js_errors
    end

    scenario "Markdown preview in the new issue form" do
      visit_and_check_page new_issue_path, css: "#issue_description"
      wait_for_atwho_to_load

      fill_in "issue_description", with: "See: #{Taxt.ref(reference.id)}"
      click_button "Rerender preview"
      i_should_see "See: Forel, 1878"

      expect_no_js_errors
    end

    scenario "Author autocomplete in the new reference form" do
      visit_and_check_page new_reference_path, css: "#reference_author_names_string"

      find_field("reference_author_names_string").send_keys("Fore")
      find(".ui-autocomplete .ui-menu-item", text: "Forel, A.").click
      expect(find_field("reference_author_names_string").value).to start_with "Forel, A.;"

      expect_no_js_errors
    end
  end
end
