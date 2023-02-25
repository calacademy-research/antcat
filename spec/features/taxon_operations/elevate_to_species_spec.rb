# frozen_string_literal: true

require 'rails_helper'

feature "Elevating subspecies to species", as: :editor do
  scenario "Elevating subspecies to species (with feed)" do
    species = create :species, name_string: "Solenopsis speccus", genus: create(:genus, name_string: "Solenopsis")
    taxon = create :subspecies, name_string: "Solenopsis speccus subbus", species: species, genus: species.genus

    visit catalog_path(taxon)
    i_will_confirm_on_the_next_step
    i_follow "Elevate to species"
    i_should_see "Subspecies was successfully elevated to a species."

    created_taxon = Taxon.find_by!(name_cache: "Solenopsis subbus")
    expect(created_taxon).to be_a(Species)

    there_should_be_an_activity "Archibald elevated the subspecies Solenopsis speccus subbus to the rank of species \\(now Solenopsis subbus\\)"
  end

  scenario "Elevating to species when the species name exists" do
    species = create :species, name_string: "Solenopsis speccus", genus: create(:genus, name_string: "Solenopsis")
    taxon = create :subspecies, name_string: "Solenopsis speccus subbus", species: species, genus: species.genus

    create :species, name_string: "Solenopsis subbus"

    visit catalog_path(taxon)
    i_will_confirm_on_the_next_step
    i_follow "Elevate to species"
    i_should_see "This name is in use by another taxon"
  end
end
