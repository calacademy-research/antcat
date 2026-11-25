# frozen_string_literal: true

require 'rails_helper'

feature "Policies and institutions for visitors" do
  scenario "The footer leads any visitor to the policies and the institutions" do
    create :wiki_page, title: "AntCat policy on name grammar and spelling",
      permanent_identifier: WikiPage::GRAMMAR_AND_SPELLING_POLICY
    create :wiki_page, title: "How to add a reference"

    visit wiki_pages_path
    within "footer" do
      i_follow "Policies"
    end
    i_should_see "AntCat policy on name grammar and spelling"
    i_should_not_see "How to add a reference"

    i_follow "All help pages"
    i_should_see "How to add a reference"

    within "footer" do
      i_follow "Institutions"
    end
    expect(page).to have_current_path institutions_path
  end

  scenario "Without policy pages the wiki index has no policies section" do
    wiki_page = create :wiki_page

    visit wiki_pages_path
    i_should_see wiki_page.title
    expect(page).to have_no_css "[data-testid='wiki-policies']"
  end
end
