# frozen_string_literal: true

require 'rails_helper'

feature "Editing a taxon" do
  background do
    i_log_in_as_a_catalog_editor_named "Archibald"
  end

  scenario "Changing protonym" do
    there_is_a_species "Eciton fusca"
    there_is_a_species_protonym_with_pages_and_form_page_9_dealate_queen "Formica fusca"

    i_go_to 'the catalog page for "Eciton fusca"'
    i_should_not_see "Formica"

    i_go_to 'the edit page for "Eciton fusca"'
    i_pick_from_the_protonym_picker "Formica fusca", "#taxon_protonym_id"
    i_press "Save"
    i_should_see "Taxon was successfully updated"
    i_should_see "Formica fusca", within: '"#protonym-synopsis"'
    i_should_see "page 9 (dealate queen)", within: '"#protonym-synopsis"'
  end

  scenario "Changing current taxon" do
    there_is_a_species_which_is_a_junior_synonym_of "Atta major", "Lasius niger"
    there_is_a_species "Eciton minor"

    i_go_to 'the catalog page for "Atta major"'
    i_should_see "synonym of current valid taxon Lasius niger"

    i_go_to 'the edit page for "Atta major"'
    i_pick_from_the_taxon_picker "Eciton minor", "#taxon_current_taxon_id"
    i_press "Save"
    i_should_see "Taxon was successfully updated"
    i_should_see "synonym of current valid taxon Eciton minor"
  end

  scenario "Changing incertae sedis (with edit summary)" do
    there_is_a_genus "Atta"

    i_go_to 'the catalog page for "Atta"'
    i_should_not_see "incertae sedis in subfamily"

    i_go_to 'the edit page for "Atta"'
    i_select "Subfamily", from: "taxon_incertae_sedis_in"
    i_fill_in "edit_summary", with: "fix incertae sedis"
    i_press "Save"
    i_should_be_on 'the catalog page for "Atta"'
    i_should_see "incertae sedis in subfamily"

    i_go_to 'the activity feed'
    i_should_see "Archibald edited the genus Atta", within: 'the activity feed'
    i_should_see_the_edit_summary "fix incertae sedis"
  end

  scenario "Changing gender of genus-group name" do
    there_is_a_genus "Atta"

    i_go_to 'the catalog page for "Atta"'
    i_should_not_see "masculine"

    i_go_to 'the edit page for "Atta"'
    i_select "masculine", from: "taxon_name_attributes_gender"
    i_press "Save"
    i_should_be_on 'the catalog page for "Atta"'
    i_should_see "masculine"
  end
end
