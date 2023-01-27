# frozen_string_literal: true

require 'rails_helper'

feature "Create obsolete combination" do
  background do
    i_log_in_as_a_catalog_editor_named "Archibald"
  end

  scenario "Creating a missing obsolete combination (with feed)" do
    genus = create :genus, name_string: "Pyramica"
    create :species, name_string: "Strumigenys ravidura"

    i_go_to 'the catalog page for "Strumigenys ravidura"'
    i_follow "Create obsolete combination"
    i_pick_from_the_taxon_picker "Pyramica", "#obsolete_genus_id"
    click_button "Create!"
    i_should_be_on 'the catalog page for "Pyramica ravidura"'

    created_taxon = Taxon.find_by!(name_cache: "Pyramica ravidura")
    expect(created_taxon.genus).to eq genus

    i_go_to 'the activity feed'
    i_should_see "Archibald created the obsolete combination Pyramica ravidura", within: 'the activity feed'
  end
end
