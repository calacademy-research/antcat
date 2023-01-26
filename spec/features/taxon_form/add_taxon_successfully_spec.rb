# frozen_string_literal: true

require 'rails_helper'

feature "Adding a taxon successfully" do
  background do
    i_log_in_as_a_catalog_editor_named "Archibald"
    this_reference_exists author: "Fisher", year: 2004
    the_default_reference_is "Fisher, 2004"
  end

  scenario "Adding a genus" do
    there_is_a_subfamily "Formicinae"

    i_go_to 'the catalog page for "Formicinae"'
    i_follow "Add genus"
    i_set_the_name_to "Atta"
    i_set_the_protonym_name_to "Eciton"
    i_fill_in "taxon_protonym_attributes_authorship_attributes_pages", with: "page 35"
    i_press "Save"
    i_should_be_on 'the catalog page for "Atta"'
    i_should_see "Eciton", within: 'the protonym'

    i_go_to 'the catalog page for "Formicinae"'
    i_should_see "Atta", within: 'the taxon browser'
  end

  scenario "Adding a genus which has a tribe" do
    there_is_a_tribe "Ecitonini"

    i_go_to 'the catalog page for "Ecitonini"'
    i_follow "Add genus"
    i_set_the_name_to "Eciton"
    i_set_the_protonym_name_to "Eciton"
    i_fill_in "taxon_protonym_attributes_authorship_attributes_pages", with: "page 35"
    i_press "Save"
    i_should_be_on 'the catalog page for "Eciton"'
  end

  scenario "Adding a subgenus" do
    there_is_a_genus "Camponotus"

    i_go_to 'the catalog page for "Camponotus"'
    i_follow "Add subgenus"
    i_set_the_name_to "Camponotus (Mayria)"
    i_set_the_protonym_name_to "Mayria"
    i_fill_in "taxon_protonym_attributes_authorship_attributes_pages", with: "page 35"
    i_press "Save"
    i_should_be_on 'the catalog page for "Camponotus (Mayria)"'
    i_should_see "Mayria", within: 'the protonym'

    i_go_to 'the catalog page for "Camponotus"'
    i_follow "Subgenera"
    i_should_see "Mayria", within: 'the taxon browser'
  end

  scenario "Adding a species (with edit summary)" do
    there_is_a_genus "Eciton"

    i_go_to 'the catalog page for "Eciton"'
    i_follow "Add species"
    i_set_the_name_to "Eciton major"
    i_set_the_protonym_name_to "Eciton major"
    i_fill_in "taxon_protonym_attributes_authorship_attributes_pages", with: "page 35"
    i_fill_in "edit_summary", with: "cool new species"
    i_press "Save"
    i_should_be_on 'the catalog page for "Eciton major"'
    i_should_see "Eciton major", within: 'the protonym'
    i_should_see "Add another"

    i_go_to 'the activity feed'
    i_should_see "Archibald added the species Eciton major to the genus Eciton", within: 'the activity feed'
    i_should_see_the_edit_summary "cool new species"
  end

  scenario "Adding a species to a subgenus" do
    there_is_a_subgenus_in_the_genus "Dolichoderus (Subdolichoderus)", "Dolichoderus"

    i_go_to 'the catalog page for "Dolichoderus (Subdolichoderus)"'
    i_follow "Add species"
    i_set_the_name_to "Dolichoderus major"
    i_set_the_protonym_name_to "Dolichoderus major"
    i_fill_in "taxon_protonym_attributes_authorship_attributes_pages", with: "page 35"
    i_press "Save"
    i_should_be_on 'the catalog page for "Dolichoderus major"'
    i_should_see "Dolichoderus major", within: 'the protonym'
  end

  scenario "Adding a subspecies" do
    there_is_a_species_in_the_genus "Eciton major", "Eciton"

    i_go_to 'the catalog page for "Eciton major"'
    i_follow "Add subspecies"
    i_set_the_name_to "Eciton major infra"
    i_set_the_protonym_name_to "Eciton major infra"
    i_fill_in "taxon_protonym_attributes_authorship_attributes_pages", with: "page 35"
    i_press "Save"
    i_should_be_on 'the catalog page for "Eciton major infra"'
    i_should_see "infra", within: 'the taxon browser'
    i_should_see "Eciton major infra", within: 'the protonym'
  end

  scenario "Adding a subfamily" do
    the_formicidae_family_exists

    i_go_to 'the main page'
    i_follow "Add subfamily"
    i_set_the_name_to "Dorylinae"
    i_set_the_protonym_name_to "Dorylinae"
    i_fill_in "taxon_protonym_attributes_authorship_attributes_pages", with: "page 35"
    i_press "Save"
    i_should_be_on 'the catalog page for "Dorylinae"'
    i_should_see "Dorylinae", within: 'the protonym'
    i_should_see "Dorylinae", within: 'the taxon browser'
  end

  scenario "Adding a tribe (and copy name to protonym)", :skip_ci, :js do
    there_is_a_subfamily "Formicinae"

    i_go_to 'the catalog page for "Formicinae"'
    i_follow "Add tribe"
    i_set_the_name_to "Dorylini"
    i_click_css "#copy-name-to-protonym-js-hook"
    i_fill_in "taxon_protonym_attributes_authorship_attributes_pages", with: "page 35"
    i_press "Save"
    i_should_be_on 'the catalog page for "Dorylini"'
    i_should_see "Dorylini", within: 'the protonym'

    i_go_to 'the catalog page for "Formicinae"'
    i_should_see "Tribes of Formicinae: Dorylini"
  end
end
