# frozen_string_literal: true

require 'rails_helper'

feature "Adding a taxon successfully", as: :editor do
  background do
    default_reference = create :any_reference
    References::DefaultReference.stub(:get).and_return(default_reference)
  end

  scenario "Adding a subfamily" do
    create :family, :formicidae

    visit root_path
    i_follow "Add subfamily"
    fill_in "taxon_name_string", with: "Dorylinae"
    fill_in "protonym_name_string", with: "Dorylinae"
    fill_in "taxon_protonym_attributes_authorship_attributes_pages", with: "page 35"
    expect { click_button "Save" }.to change { Taxon.count }.by(1)

    created_taxon = Taxon.last
    i_should_be_on catalog_path(created_taxon)
    expect(created_taxon.name_cache).to eq "Dorylinae"
  end

  scenario "Adding a tribe (and copy name to protonym)", :skip_ci, :js do
    taxon = create :subfamily, name_string: "Formicinae"

    visit catalog_path(taxon)
    i_follow "Add tribe"
    fill_in "taxon_name_string", with: "Dorylini"
    find("#copy-name-to-protonym-js-hook").click
    fill_in "taxon_protonym_attributes_authorship_attributes_pages", with: "page 35"
    expect { click_button "Save" }.to change { Taxon.count }.by(1)

    created_taxon = Taxon.last
    i_should_be_on catalog_path(created_taxon)
    expect(created_taxon.name_cache).to eq "Dorylini"
  end

  scenario "Adding a genus" do
    taxon = create :subfamily

    visit catalog_path(taxon)
    i_follow "Add genus"
    fill_in "taxon_name_string", with: "Atta"
    fill_in "protonym_name_string", with: "Eciton"
    fill_in "taxon_protonym_attributes_authorship_attributes_pages", with: "page 35"
    expect { click_button "Save" }.to change { Taxon.count }.by(1)

    created_taxon = Taxon.last
    i_should_be_on catalog_path(created_taxon)
    expect(created_taxon.name_cache).to eq "Atta"
    expect(created_taxon.protonym.name.name).to eq "Eciton"
  end

  scenario "Adding a genus which has a tribe" do
    taxon = create :tribe, name_string: "Ecitonini"

    visit catalog_path(taxon)
    i_follow "Add genus"
    fill_in "taxon_name_string", with: "Eciton"
    fill_in "protonym_name_string", with: "Eciton"
    fill_in "taxon_protonym_attributes_authorship_attributes_pages", with: "page 35"
    expect { click_button "Save" }.to change { Taxon.count }.by(1)

    created_taxon = Taxon.last
    i_should_be_on catalog_path(created_taxon)
    expect(created_taxon.name_cache).to eq "Eciton"
  end

  scenario "Adding a subgenus" do
    taxon = create :genus, name_string: "Camponotus"

    visit catalog_path(taxon)
    i_follow "Add subgenus"
    fill_in "taxon_name_string", with: "Camponotus (Mayria)"
    fill_in "protonym_name_string", with: "Mayria"
    fill_in "taxon_protonym_attributes_authorship_attributes_pages", with: "page 35"
    expect { click_button "Save" }.to change { Taxon.count }.by(1)

    created_taxon = Taxon.last
    i_should_be_on catalog_path(created_taxon)
    expect(created_taxon.name_cache).to eq "Camponotus (Mayria)"
    expect(created_taxon.protonym.name.name).to eq "Mayria"
  end

  scenario "Adding a species (with edit summary)" do
    taxon = create :genus, name_string: "Eciton"

    visit catalog_path(taxon)
    i_follow "Add species"
    fill_in "taxon_name_string", with: "Eciton major"
    fill_in "protonym_name_string", with: "Eciton major"
    fill_in "taxon_protonym_attributes_authorship_attributes_pages", with: "page 35"
    fill_in "edit_summary", with: "cool new species"
    expect { click_button "Save" }.to change { Taxon.count }.by(1)

    created_taxon = Taxon.last
    i_should_be_on catalog_path(created_taxon)
    expect(created_taxon.name_cache).to eq "Eciton major"

    there_should_be_an_activity "Archibald added the species Eciton major to the genus Eciton", edit_summary: "cool new species"
  end

  scenario "Adding a species to a subgenus" do
    genus = create(:genus, name_string: "Dolichoderus")
    taxon = create :subgenus, name_string: "Dolichoderus (Subdolichoderus)", genus: genus

    visit catalog_path(taxon)
    i_follow "Add species"
    fill_in "taxon_name_string", with: "Dolichoderus major"
    fill_in "protonym_name_string", with: "Dolichoderus major"
    fill_in "taxon_protonym_attributes_authorship_attributes_pages", with: "page 35"
    expect { click_button "Save" }.to change { Taxon.count }.by(1)

    created_taxon = Taxon.last
    i_should_be_on catalog_path(created_taxon)
    expect(created_taxon.name_cache).to eq "Dolichoderus major"
  end

  scenario "Adding a subspecies" do
    genus = create(:genus, name_string: "Eciton")
    taxon = create :species, name_string: "Eciton major", genus: genus

    visit catalog_path(taxon)
    i_follow "Add subspecies"
    fill_in "taxon_name_string", with: "Eciton major infra"
    fill_in "protonym_name_string", with: "Eciton major infra"
    fill_in "taxon_protonym_attributes_authorship_attributes_pages", with: "page 35"
    expect { click_button "Save" }.to change { Taxon.count }.by(1)

    created_taxon = Taxon.last
    i_should_be_on catalog_path(created_taxon)
    expect(created_taxon.name_cache).to eq "Eciton major infra"
  end
end
