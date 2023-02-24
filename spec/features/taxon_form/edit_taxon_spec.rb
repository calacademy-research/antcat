# frozen_string_literal: true

require 'rails_helper'

feature "Editing a taxon" do
  background do
    i_log_in_as_a_catalog_editor_named "Archibald"
  end

  scenario "Changing protonym" do
    taxon = create :species
    protonym = create :protonym, :species_group, name: create(:species_name, name: "Formica fusca")

    expect(taxon.reload.protonym).not_to eq protonym

    visit edit_taxon_path(taxon)
    i_pick_from_the_protonym_picker "Formica fusca", "#taxon_protonym_id"
    click_button "Save"
    i_should_see "Taxon was successfully updated"
    expect(taxon.reload.protonym).to eq protonym
  end

  scenario "Changing current taxon" do
    # Species with a junior synonym.
    senior = create :species, name_string: "Lasius niger"
    taxon = create :species, :synonym, name_string: "Atta major", current_taxon: senior

    create :species, name_string: "Eciton minor"

    visit catalog_path(taxon)
    i_should_see "synonym of current valid taxon Lasius niger"

    visit edit_taxon_path(taxon)
    i_pick_from_the_taxon_picker "Eciton minor", "#taxon_current_taxon_id"
    click_button "Save"
    i_should_see "Taxon was successfully updated"
    i_should_see "synonym of current valid taxon Eciton minor"
  end

  scenario "Changing incertae sedis (with edit summary)" do
    taxon = create :genus, name_string: "Atta"

    visit catalog_path(taxon)
    i_should_not_see "incertae sedis in subfamily"

    visit edit_taxon_path(taxon)
    select "Subfamily", from: "taxon_incertae_sedis_in"
    fill_in "edit_summary", with: "fix incertae sedis"
    click_button "Save"
    i_should_be_on 'the catalog page for "Atta"'
    i_should_see "incertae sedis in subfamily"

    there_should_be_an_activity "Archibald edited the genus Atta", edit_summary: "fix incertae sedis"
  end

  scenario "Changing gender of genus-group name" do
    taxon = create :genus, name_string: "Atta"

    visit catalog_path(taxon)
    i_should_not_see "masculine"

    visit edit_taxon_path(taxon)
    select "masculine", from: "taxon_name_attributes_gender"
    click_button "Save"
    i_should_be_on 'the catalog page for "Atta"'
    i_should_see "masculine"
  end
end
