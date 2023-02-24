# frozen_string_literal: true

require 'rails_helper'

feature "Converting a species to a subspecies", as: :editor do
  scenario "Converting a species to a subspecies (with feed)" do
    genus = create(:genus, name_string: "Camponotus")
    taxon = create :species, name_string: "Camponotus dallatorei", genus: genus
    create :species, name_string: "Camponotus alii", genus: genus

    visit catalog_path(taxon)
    i_follow "Convert to subspecies"
    i_should_see "Convert species"
    i_should_see "to be a subspecies of"

    i_pick_from_the_taxon_picker "Camponotus alii", "#new_species_id"
    click_button "Convert"
    i_should_be_on 'the catalog page for "Camponotus alii dallatorei"'

    created_taxon = Taxon.find_by!(name_cache: "Camponotus alii dallatorei")
    expect(created_taxon).to be_a(Subspecies)

    there_should_be_an_activity "Archibald converted the species Camponotus dallatorei to a subspecies \\(now Camponotus alii dallatorei\\)"
  end

  scenario "Converting a species to a subspecies when it already exists" do
    genus = create(:genus, name_string: "Camponotus")
    species = create :species, name_string: "Camponotus alii", genus: genus
    create :subspecies, name_string: "Camponotus alii dallatorei", species: species, genus: species.genus
    taxon = create :species, name_string: "Camponotus dallatorei", genus: genus

    visit catalog_path(taxon)
    i_follow "Convert to subspecies"
    i_pick_from_the_taxon_picker "Camponotus alii", "#new_species_id"
    click_button "Convert"
    i_should_see "This name is in use by another taxon"
  end
end
