# frozen_string_literal: true

require 'rails_helper'

feature "Reference sections" do
  feature "Browse reference sections", as: :user do
    scenario "Filtering reference sections by search query" do
      create :reference_section, references_taxt: "typo of Forel"
      create :reference_section, references_taxt: "typo of August"

      visit reference_sections_path
      i_should_see "typo of Forel"
      i_should_see "typo of August"

      fill_in "q", with: "Forel"
      click_button "Search"
      i_should_see "typo of Forel"
      i_should_not_see "typo of August"

      fill_in "q", with: "asdasdasd"
      click_button "Search"
      i_should_not_see "typo of Forel"
      i_should_not_see "typo of August"
    end
  end

  feature "Editing references sections", as: :editor do
    def the_reference_section_should_be content
      element = first('[data-taxt-editor-target=presenter]')
      expect(element).to have_content(content)
    end

    scenario "Adding a reference section (with edit summary)" do
      taxon = create :genus, name_string: "Atta"

      visit edit_taxon_path(taxon)

      find(:testid, "add-reference-section-button").click
      fill_in "references_taxt", with: "New reference"
      fill_in "edit_summary", with: "added new stuff"
      expect { click_button "Save" }.to change { ReferenceSection.count }.by(1)
      the_reference_section_should_be "New reference"

      there_should_be_an_activity "Archibald added the reference section ##{ReferenceSection.last.id} belonging to Atta", edit_summary: "added new stuff"
    end

    scenario "Editing a reference section (with edit summary)", :js, :protect_from_forgery do
      taxon = create :subfamily, name_string: "Dolichoderinae"
      reference_section = create :reference_section, references_taxt: "Original reference", taxon: taxon

      visit edit_taxon_path(taxon)
      the_reference_section_should_be "Original reference"

      wait_for_taxt_editors_to_load
      find(:testid, 'reference-section-taxt-editor-edit-button').click
      fill_in "references_taxt", with: "(none)"
      within "[data-taxt-editor-target=editor]" do
        fill_in "edit_summary", with: "fix typo"
      end
      find(:testid, 'reference-section-taxt-editor-save-button').click
      i_should_not_see "Original reference"
      the_reference_section_should_be "(none)"

      there_should_be_an_activity "Archibald edited the reference section ##{reference_section.id} belonging to Dolichoderinae", edit_summary: "fix typo"
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

    scenario "Editing a reference section, but cancelling", :js, :protect_from_forgery do
      taxon = create :subfamily
      create :reference_section, references_taxt: "Original reference", taxon: taxon

      visit edit_taxon_path(taxon)
      wait_for_taxt_editors_to_load
      find(:testid, 'reference-section-taxt-editor-edit-button').click
      fill_in "references_taxt", with: "(none)"
      find(:testid, 'reference-section-taxt-editor-cancel-button').click
      the_reference_section_should_be "Original reference"
    end

    scenario "Deleting a reference section (with feed)", :js, :protect_from_forgery do
      taxon = create :subfamily, name_string: "Dolichoderinae"
      reference_section = create :reference_section, taxon: taxon

      visit edit_taxon_path(taxon)
      wait_for_taxt_editors_to_load
      find(:testid, 'reference-section-taxt-editor-edit-button').click
      within "[data-taxt-editor-target=editor]" do
        fill_in "edit_summary", with: "delete duplicate"
      end
      i_will_confirm_on_the_next_step
      expect { find(:testid, 'reference-section-taxt-editor-delete-button').click }.to change { ReferenceSection.count }.by(-1)

      there_should_be_an_activity "Archibald deleted the reference section ##{reference_section.id} belonging to Dolichoderinae",
        edit_summary: "delete duplicate"
    end
  end
end
