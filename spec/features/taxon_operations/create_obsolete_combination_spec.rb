# frozen_string_literal: true

require 'rails_helper'

feature "Create obsolete combination" do
  background do
    i_log_in_as_a_catalog_editor_named "Archibald"
  end

  scenario "Creating a missing obsolete combination (with feed)" do
    genus = create :genus, name_string: "Pyramica"
    taxon = create :species, name_string: "Strumigenys ravidura"

    visit catalog_path(taxon)
    i_follow "Create obsolete combination"
    i_pick_from_the_taxon_picker "Pyramica", "#obsolete_genus_id"
    click_button "Create!"
    i_should_be_on 'the catalog page for "Pyramica ravidura"'

    created_taxon = Taxon.find_by!(name_cache: "Pyramica ravidura")
    expect(created_taxon.genus).to eq genus

    there_should_be_an_activity "Archibald created the obsolete combination Pyramica ravidura"
  end
end
