# frozen_string_literal: true

require 'rails_helper'

# The "Policies and help" section: Policies | Names with notes | Help pages | Institutions. The same for a visitor
# and an editor; each page leads to the other three.
feature "Policies and help" do
  def the_section_bar_has_all_four_links
    within "[data-testid='policies-and-help-subnavigation']" do
      expect(page).to have_link "Policies"
      expect(page).to have_link "Names with notes"
      expect(page).to have_link "Help pages"
      expect(page).to have_link "Institutions"
    end
  end

  background do
    create :wiki_page, title: "AntCat policy on name grammar and spelling",
      permanent_identifier: WikiPage::GRAMMAR_AND_SPELLING_POLICY
    create :wiki_page, title: "Names with open questions",
      permanent_identifier: WikiPage::OPEN_GRAMMAR_AND_SPELLING_QUESTIONS
    create :wiki_page, title: "How to add a reference"
  end

  scenario "A visitor goes from the policies to the names with notes, the help pages and the institutions" do
    protonym = create :protonym
    create :notes_page, protonym: protonym, content: "## Etymological notes\n\nText."

    visit institutions_path
    within "#desktop-only-header" do
      i_follow "Policies & help"
    end
    i_should_see "AntCat policy on name grammar and spelling"
    i_should_not_see "How to add a reference"
    within "#breadcrumbs" do
      i_should_see "Policies and help"
      i_should_not_see "Editor's Panel"
    end
    the_section_bar_has_all_four_links

    i_follow "AntCat policy on name grammar and spelling"
    within "#breadcrumbs" do
      i_should_see "Policies and help"
    end
    the_section_bar_has_all_four_links

    i_follow "Names with notes", within_scope: "[data-testid='policies-and-help-subnavigation']"
    within "[data-testid='names-with-notes']" do
      i_should_see protonym.name.name
      i_should_see "Etymological notes"
    end
    i_should_see "Names with open questions"
    the_section_bar_has_all_four_links

    i_follow "Help pages", within_scope: "[data-testid='policies-and-help-subnavigation']"
    i_should_see "How to add a reference"
    the_section_bar_has_all_four_links

    i_follow "Institutions", within_scope: "[data-testid='policies-and-help-subnavigation']"
    expect(page).to have_current_path institutions_path
    within "#breadcrumbs" do
      i_should_see "Policies and help"
      i_should_not_see "Editor's Panel"
    end
    the_section_bar_has_all_four_links
  end

  scenario "The footer has the same four links" do
    visit wiki_pages_path
    within "footer" do
      expect(page).to have_link "Policies"
      expect(page).to have_link "Names with notes"
      expect(page).to have_link "Help pages"
      expect(page).to have_link "Institutions"
    end
  end

  scenario "An editor sees the same breadcrumb as a visitor", as: :editor do
    visit wiki_pages_path(policies: 1)
    within "#breadcrumbs" do
      i_should_see "Policies and help"
      i_should_not_see "Editor's Panel"
    end
  end

  scenario "An editor has the policy links beside the etymology and part-of-speech fields", as: :editor do
    protonym = create :protonym, :species_group

    visit edit_protonym_path(protonym)
    within first("[data-testid='policy-links-for-editors']") do
      expect(page).to have_link "Policy on grammar and spelling"
      expect(page).to have_link "Names with notes"
      expect(page).to have_link "Open questions"
    end
  end

  scenario "Without policy pages the help pages index has no policies section" do
    WikiPage.where.not(permanent_identifier: nil).destroy_all

    visit wiki_pages_path
    i_should_see "How to add a reference"
    expect(page).to have_no_css "[data-testid='wiki-policies']"
  end
end
