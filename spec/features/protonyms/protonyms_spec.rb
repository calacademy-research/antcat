# frozen_string_literal: true

require 'rails_helper'

feature "Protonyms", as: :helper do
  scenario "Adding a protonym with a type name" do
    create :genus, name_string: "Atta"
    create :any_reference, author_string: "Batiatus", year: 2004

    visit protonyms_path
    i_follow "New"
    fill_in "protonym_name_string", with: "Dotta"
    i_pick_from_the_taxon_picker "Atta", "#protonym_type_name_attributes_taxon_id"
    i_pick_from_the_reference_picker "Batiatus, 2004", "#protonym_authorship_attributes_reference_id"
    fill_in "protonym_authorship_attributes_pages", with: "page 35"
    select "by monotypy", from: "protonym_type_name_attributes_fixation_method"
    click_button "Save"
    i_should_see "Protonym was successfully created."
    i_should_see "Type-genus: Atta, by monotypy"

    i_follow "Edit"
    select "by original designation", from: "protonym_type_name_attributes_fixation_method"
    click_button "Save"
    i_should_see "Protonym was successfully updated"
    i_should_see "Type-genus: Atta, by original designation"
  end

  # One page of notes per name, of any rank (16 Nov 2026).
  scenario "Adding and editing the notes on a name (with edit summary)" do
    protonym = create :protonym, :genus_group

    visit protonym_path(protonym)
    i_follow "Add notes on this name"
    fill_in "notes_page_content", with: "## Type specimen notes\n\nThe type series is in two museums."
    fill_in "edit_summary", with: "notes on the types"
    click_button "Save"
    i_should_see "Successfully created the notes on this name."
    i_should_see "The type series is in two museums."
    there_should_be_an_activity "Archibald added the notes on #{protonym.name.name}", edit_summary: "notes on the types"

    visit protonym_path(protonym)
    i_should_not_see "Add notes on this name"
    i_follow_the_first "Type specimen notes"
    i_follow "Edit"
    fill_in "notes_page_content", with: "## Nomenclatural notes\n\nAvailable from the original description."
    click_button "Save"
    i_should_see "Successfully updated the notes on this name."
    i_should_see "Available from the original description."

    i_follow "History"
    i_should_see "Current version"
    i_should_see "Available from the original description."
  end

  scenario "Adding a protonym with errors" do
    visit protonyms_path
    i_follow "New"
    select "by monotypy", from: "protonym_type_name_attributes_fixation_method"
    click_button "Save"
    i_should_see "Name can't be blank"
    i_should_see "Authorship: Reference must exist"
    i_should_see "Authorship: Pages can't be blank"
    i_should_see "Type name: Taxon must exist"
  end

  scenario "Adding a protonym with unparsable name, and maintain entered fields" do
    visit protonyms_path
    i_follow "New"
    fill_in "protonym_name_string", with: "Invalid a b c d e f protonym name"
    click_button "Save"
    i_should_see "Protonym name: Could not parse name Invalid a b c d e f protonym name"
    the_field_should_contain "protonym_name_string", "Invalid a b c d e f protonym name"
  end

  scenario "Editing a protonym" do
    create :protonym, :species_group, protonym_name_string: "Formica fusca",
      authorship: create(:citation, pages: 'page 9'), forms: 'dealate queen'

    visit protonyms_path
    i_follow "Formica fusca"
    i_should_see "page 9"
    i_should_see "dealate queen"

    i_follow "Edit"
    fill_in "protonym_authorship_attributes_pages", with: "page 35"
    fill_in "protonym_forms", with: "male"
    fill_in "protonym_locality", with: "Lund"
    select "Malagasy", from: "protonym_bioregion"
    click_button "Save"
    i_should_see "Protonym was successfully updated"
    i_should_see "page 35"
    i_should_see "male"
    i_should_see "LUND"
    i_should_see "Malagasy"

    i_follow "Edit"
    fill_in "protonym_authorship_attributes_pages", with: "page 35"
    fill_in "protonym_forms", with: "male"
    the_field_should_contain "protonym_locality", "Lund"
  end

  scenario "Editing type fields" do
    protonym = create :protonym, :genus_group

    visit edit_protonym_path(protonym)
    fill_in "protonym_primary_type_information_taxt", with: "Madagascar: Prov. Tolliara"
    fill_in "protonym_secondary_type_information_taxt", with: "A neotype had also been designated"
    fill_in "protonym_type_notes_taxt", with: "Note: Typo in Toliara"
    click_button "Save"
    i_should_see "Protonym was successfully updated"
    i_should_see "Madagascar: Prov. Tolliara"
    i_should_see "A neotype had also been designated"
    i_should_see "Note: Typo in Toliara"
  end

  scenario "Editing a protonym with errors" do
    protonym = create :protonym, :genus_group

    visit edit_protonym_path(protonym)
    fill_in "protonym_authorship_attributes_pages", with: ""
    select "by subsequent designation of", from: "protonym_type_name_attributes_fixation_method"
    click_button "Save"
    i_should_see "Authorship: Pages can't be blank"
    i_should_see "Type name: Taxon must exist"
    i_should_see "Type name: Reference must be set for 'by subsequent designation of'"
    i_should_see "Type name: Pages must be set for 'by subsequent designation of'"
  end
end
