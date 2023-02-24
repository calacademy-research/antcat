# frozen_string_literal: true

require 'rails_helper'

feature "Editing references sections" do
  def the_reference_section_should_be_empty
    expect(page).not_to have_css '#reference-sections .reference_section'
  end

  def the_reference_section_should_be content
    element = first('#references-section').find('.taxt-presenter')
    expect(element).to have_content(content)
  end

  background do
    i_log_in_as_a_catalog_editor_named "Archibald"
  end

  scenario "Adding a reference section (with edit summary)" do
    taxon = create :genus, name_string: "Atta"

    visit edit_taxon_path(taxon)
    the_reference_section_should_be_empty

    i_click_on 'the add reference section button'
    fill_in "references_taxt", with: "New reference"
    fill_in "edit_summary", with: "added new stuff"
    click_button "Save"
    the_reference_section_should_be "New reference"

    there_should_be_an_activity "Archibald added the reference section #\\d+ belonging to Atta", edit_summary: "added new stuff"
  end

  scenario "Editing a reference section (with edit summary)", :js do
    taxon = create :subfamily, "Dolichoderinae"
    create :reference_section, references_taxt: "Original reference", taxon: taxon

    visit edit_taxon_path(taxon)
    the_reference_section_should_be "Original reference"

    wait_for_taxt_editors_to_load
    i_click_on 'the edit reference section button'
    fill_in "references_taxt", with: "(none)"
    within "#references-section" do
      fill_in "edit_summary", with: "fix typo"
    end
    i_click_on 'the save reference section button'
    i_should_not_see "Original reference"
    the_reference_section_should_be "(none)"

    there_should_be_an_activity "Archibald edited the reference section #\\d+ belonging to Dolichoderinae", edit_summary: "fix typo"
  end

  scenario "Editing a reference section (without JavaScript)" do
    reference_section = create :reference_section, references_taxt: "California checklist"

    visit reference_section_path(reference_section)
    i_should_see "California checklist"

    i_follow "Edit"
    fill_in "references_taxt", with: "reference section content"
    click_button "Save"
    i_should_see "Successfully updated reference section."
    i_should_see "reference section content"
  end

  scenario "Editing a reference section, but cancelling", :js do
    taxon = create :subfamily, "Dolichoderinae"
    create :reference_section, references_taxt: "Original reference", taxon: taxon

    visit edit_taxon_path(taxon)
    wait_for_taxt_editors_to_load
    i_click_on 'the edit reference section button'
    fill_in "references_taxt", with: "(none)"
    i_click_on 'the cancel reference section button'
    the_reference_section_should_be "Original reference"
  end

  scenario "Deleting a reference section (with feed)", :js do
    taxon = create :subfamily, "Dolichoderinae"
    create :reference_section, references_taxt: "Original reference", taxon: taxon

    visit edit_taxon_path(taxon)
    wait_for_taxt_editors_to_load
    i_click_on 'the edit reference section button'
    i_will_confirm_on_the_next_step
    i_click_on 'the delete reference section button'
    the_reference_section_should_be_empty

    there_should_be_an_activity "Archibald deleted the reference section #\\d+ belonging to Dolichoderinae"
  end
end
