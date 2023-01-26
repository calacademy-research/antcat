# frozen_string_literal: true

require 'rails_helper'

feature "Manage protonyms" do
  background do
    i_log_in_as_a_helper_editor
  end

  scenario "Adding a protonym with a type name" do
    there_is_a_genus "Atta"
    this_reference_exists author: "Batiatus", year: 2004

    i_go_to 'the protonyms page'
    i_follow "New"
    i_set_the_protonym_name_to "Dotta"
    i_pick_from_the_taxon_picker "Atta", "#protonym_type_name_attributes_taxon_id"
    i_pick_from_the_reference_picker "Batiatus, 2004", "#protonym_authorship_attributes_reference_id"
    i_fill_in "protonym_authorship_attributes_pages", with: "page 35"
    i_select "by monotypy", from: "protonym_type_name_attributes_fixation_method"
    i_press "Save"
    i_should_see "Protonym was successfully created."
    i_should_see "Type-genus: Atta, by monotypy"

    i_follow "Edit"
    i_select "by original designation", from: "protonym_type_name_attributes_fixation_method"
    i_press "Save"
    i_should_see "Protonym was successfully updated"
    i_should_see "Type-genus: Atta, by original designation"
  end

  scenario "Adding a protonym with errors" do
    i_go_to 'the protonyms page'
    i_follow "New"
    i_select "by monotypy", from: "protonym_type_name_attributes_fixation_method"
    i_press "Save"
    i_should_see "Name can't be blank"
    i_should_see "Authorship: Reference must exist"
    i_should_see "Authorship: Pages can't be blank"
    i_should_see "Type name: Taxon must exist"
  end

  scenario "Adding a protonym with unparsable name, and maintain entered fields" do
    i_go_to 'the protonyms page'
    i_follow "New"
    i_set_the_protonym_name_to "Invalid a b c d e f protonym name"
    i_press "Save"
    i_should_see "Protonym name: Could not parse name Invalid a b c d e f protonym name"
    the_field_should_contain "protonym_name_string", "Invalid a b c d e f protonym name"
  end

  scenario "Editing a protonym" do
    there_is_a_species_protonym_with_pages_and_form_page_9_dealate_queen "Formica fusca"

    i_go_to 'the protonyms page'
    i_follow "Formica fusca"
    i_should_see "page 9"
    i_should_see "dealate queen"

    i_follow "Edit"
    i_fill_in "protonym_authorship_attributes_pages", with: "page 35"
    i_fill_in "protonym_forms", with: "male"
    i_fill_in "protonym_locality", with: "Lund"
    i_select "Malagasy", from: "protonym_bioregion"
    i_press "Save"
    i_should_see "Protonym was successfully updated"
    i_should_see "page 35"
    i_should_see "male"
    i_should_see "LUND"
    i_should_see "Malagasy"

    i_follow "Edit"
    i_fill_in "protonym_authorship_attributes_pages", with: "page 35"
    i_fill_in "protonym_forms", with: "male"
    the_field_should_contain "protonym_locality", "Lund"
  end

  scenario "Editing type fields" do
    there_is_a_genus_protonym "Formica"

    i_go_to 'the edit protonym page for "Formica"'
    i_fill_in "protonym_primary_type_information_taxt", with: "Madagascar: Prov. Tolliara"
    i_fill_in "protonym_secondary_type_information_taxt", with: "A neotype had also been designated"
    i_fill_in "protonym_type_notes_taxt", with: "Note: Typo in Toliara"
    i_press "Save"
    i_should_see "Protonym was successfully updated"
    i_should_see "Madagascar: Prov. Tolliara"
    i_should_see "A neotype had also been designated"
    i_should_see "Note: Typo in Toliara"
  end

  scenario "Editing a protonym with errors" do
    there_is_a_genus_protonym "Formica"

    i_go_to 'the edit protonym page for "Formica"'
    i_fill_in "protonym_authorship_attributes_pages", with: ""
    i_select "by subsequent designation of", from: "protonym_type_name_attributes_fixation_method"
    i_press "Save"
    i_should_see "Authorship: Pages can't be blank"
    i_should_see "Type name: Taxon must exist"
    i_should_see "Type name: Reference must be set for 'by subsequent designation of'"
    i_should_see "Type name: Pages must be set for 'by subsequent designation of'"
  end
end
