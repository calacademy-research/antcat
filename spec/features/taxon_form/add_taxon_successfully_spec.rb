# frozen_string_literal: true

require 'rails_helper'

feature "Adding a taxon successfully" do
  background do
    i_log_in_as_a_catalog_editor_named "Archibald"
    default_reference = create :any_reference, author_string: "Fisher", year: 2004
    References::DefaultReference.stub(:get).and_return(default_reference)
  end

  scenario "Adding a genus" do
    create :subfamily, name_string: "Formicinae"

    i_go_to 'the catalog page for "Formicinae"'
    i_follow "Add genus"
    fill_in "taxon_name_string", with: "Atta"
    fill_in "protonym_name_string", with: "Eciton"
    fill_in "taxon_protonym_attributes_authorship_attributes_pages", with: "page 35"
    click_button "Save"
    i_should_be_on 'the catalog page for "Atta"'
    i_should_see "Eciton", within: 'the protonym'

    i_go_to 'the catalog page for "Formicinae"'
    i_should_see "Atta", within: 'the taxon browser'
  end

  scenario "Adding a genus which has a tribe" do
    create :tribe, name_string: "Ecitonini"

    i_go_to 'the catalog page for "Ecitonini"'
    i_follow "Add genus"
    fill_in "taxon_name_string", with: "Eciton"
    fill_in "protonym_name_string", with: "Eciton"
    fill_in "taxon_protonym_attributes_authorship_attributes_pages", with: "page 35"
    click_button "Save"
    i_should_be_on 'the catalog page for "Eciton"'
  end

  scenario "Adding a subgenus" do
    create :genus, name_string: "Camponotus"

    i_go_to 'the catalog page for "Camponotus"'
    i_follow "Add subgenus"
    fill_in "taxon_name_string", with: "Camponotus (Mayria)"
    fill_in "protonym_name_string", with: "Mayria"
    fill_in "taxon_protonym_attributes_authorship_attributes_pages", with: "page 35"
    click_button "Save"
    i_should_be_on 'the catalog page for "Camponotus (Mayria)"'
    i_should_see "Mayria", within: 'the protonym'

    i_go_to 'the catalog page for "Camponotus"'
    i_follow "Subgenera"
    i_should_see "Mayria", within: 'the taxon browser'
  end

  scenario "Adding a species (with edit summary)" do
    create :genus, name_string: "Eciton"

    i_go_to 'the catalog page for "Eciton"'
    i_follow "Add species"
    fill_in "taxon_name_string", with: "Eciton major"
    fill_in "protonym_name_string", with: "Eciton major"
    fill_in "taxon_protonym_attributes_authorship_attributes_pages", with: "page 35"
    fill_in "edit_summary", with: "cool new species"
    click_button "Save"
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
    fill_in "taxon_name_string", with: "Dolichoderus major"
    fill_in "protonym_name_string", with: "Dolichoderus major"
    fill_in "taxon_protonym_attributes_authorship_attributes_pages", with: "page 35"
    click_button "Save"
    i_should_be_on 'the catalog page for "Dolichoderus major"'
    i_should_see "Dolichoderus major", within: 'the protonym'
  end

  scenario "Adding a subspecies" do
    there_is_a_species_in_the_genus "Eciton major", "Eciton"

    i_go_to 'the catalog page for "Eciton major"'
    i_follow "Add subspecies"
    fill_in "taxon_name_string", with: "Eciton major infra"
    fill_in "protonym_name_string", with: "Eciton major infra"
    fill_in "taxon_protonym_attributes_authorship_attributes_pages", with: "page 35"
    click_button "Save"
    i_should_be_on 'the catalog page for "Eciton major infra"'
    i_should_see "infra", within: 'the taxon browser'
    i_should_see "Eciton major infra", within: 'the protonym'
  end

  scenario "Adding a subfamily" do
    create :family, :formicidae

    i_go_to 'the main page'
    i_follow "Add subfamily"
    fill_in "taxon_name_string", with: "Dorylinae"
    fill_in "protonym_name_string", with: "Dorylinae"
    fill_in "taxon_protonym_attributes_authorship_attributes_pages", with: "page 35"
    click_button "Save"
    i_should_be_on 'the catalog page for "Dorylinae"'
    i_should_see "Dorylinae", within: 'the protonym'
    i_should_see "Dorylinae", within: 'the taxon browser'
  end

  scenario "Adding a tribe (and copy name to protonym)", :skip_ci, :js do
    create :subfamily, name_string: "Formicinae"

    i_go_to 'the catalog page for "Formicinae"'
    i_follow "Add tribe"
    fill_in "taxon_name_string", with: "Dorylini"
    i_click_css "#copy-name-to-protonym-js-hook"
    fill_in "taxon_protonym_attributes_authorship_attributes_pages", with: "page 35"
    click_button "Save"
    i_should_be_on 'the catalog page for "Dorylini"'
    i_should_see "Dorylini", within: 'the protonym'

    i_go_to 'the catalog page for "Formicinae"'
    i_should_see "Tribes of Formicinae: Dorylini"
  end
end
