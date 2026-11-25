# frozen_string_literal: true

require 'rails_helper'

feature "Wiki pages", as: :editor do
  scenario "Adding a wiki page (with edit summary)" do
    visit wiki_pages_path
    i_should_see "There are currently no wiki pages"

    i_follow "New"
    fill_in "wiki_page_title", with: "Bibliography guidelines"
    fill_in "wiki_page_content", with: "In the title, use capitals only"
    fill_in "edit_summary", with: "added help page"
    click_button "Save"
    i_should_see "Successfully created wiki page"

    visit wiki_pages_path
    i_should_see "Bibliography guidelines"

    i_follow_the_first "Bibliography guidelines"
    i_should_see "In the title, use capitals only"

    there_should_be_an_activity "Archibald added the wiki page Bibliography guidelines", edit_summary: "added help page"
  end

  scenario "Editing a wiki page (with edit summary)" do
    create :wiki_page, title: "Catalog guidelines"

    visit wiki_pages_path
    i_follow_the_first "Catalog guidelines"
    i_follow "Edit"
    fill_in "wiki_page_title", with: "Name guidelines"
    fill_in "wiki_page_content", with: "Genus names must start with a capital letter"
    fill_in "edit_summary", with: "updated info"
    click_button "Save"
    i_should_see "Successfully updated wiki page"

    visit wiki_pages_path
    i_should_see "Name guidelines"

    i_follow_the_first "Name guidelines"
    i_should_see "Genus names must start with a capital letter"

    there_should_be_an_activity "Archibald edited the wiki page Name guidelines", edit_summary: "updated info"
  end

  scenario "A superadmin gives a page the identifier that lists it among the policies", as: :superadmin do
    wiki_page = create :wiki_page, title: "AntCat policy on derived etymologies"

    visit edit_wiki_page_path(wiki_page)
    select WikiPage::DERIVED_ETYMOLOGIES_POLICY, from: "wiki_page_permanent_identifier"
    click_button "Save"
    i_should_see "Successfully updated wiki page"

    visit wiki_pages_path
    within "[data-testid='wiki-policies']" do
      i_should_see "AntCat policy on derived etymologies"
    end
  end

  scenario "An editor is not offered the identifier" do
    wiki_page = create :wiki_page

    visit edit_wiki_page_path(wiki_page)
    expect(page).to have_no_field "wiki_page_permanent_identifier"
  end
end

feature "Policies and institutions for visitors" do
  scenario "The footer leads any visitor to the policies and the institutions" do
    create :wiki_page, title: "AntCat policy on name grammar and spelling",
      permanent_identifier: WikiPage::GRAMMAR_AND_SPELLING_POLICY
    create :wiki_page, title: "How to add a reference"

    visit wiki_pages_path
    within "footer" do
      i_follow "Policies"
    end
    within "[data-testid='wiki-policies']" do
      i_should_see "AntCat policy on name grammar and spelling"
      i_should_not_see "How to add a reference"
    end

    within "footer" do
      i_follow "Institutions"
    end
    expect(page).to have_current_path institutions_path
  end

  scenario "Without policy pages the wiki index has no policies section" do
    create :wiki_page

    visit wiki_pages_path
    expect(page).to have_no_css "[data-testid='wiki-policies']"
  end
end
