# frozen_string_literal: true

require 'rails_helper'

feature "Create obsolete combination", as: :editor do
  scenario "Creating a missing obsolete combination (with feed)" do
    genus = create :genus, name_string: "Pyramica"
    taxon = create :species, name_string: "Strumigenys ravidura"

    visit catalog_path(taxon)
    i_follow "Create obsolete combination"
    i_pick_from_the_taxon_picker "Pyramica", "#obsolete_genus_id"
    click_button "Create!"

    created_taxon = Taxon.find_by!(name_cache: "Pyramica ravidura")
    expect(created_taxon.genus).to eq genus
    i_should_be_on catalog_path(created_taxon)

    there_should_be_an_activity "Archibald created the obsolete combination Pyramica ravidura"
  end
end
