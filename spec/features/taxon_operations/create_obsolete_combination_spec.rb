# frozen_string_literal: true

require 'rails_helper'

feature "Create obsolete combination" do
  background do
    i_log_in_as_a_catalog_editor_named "Archibald"
  end

  scenario "Creating a missing obsolete combination (with feed)" do
    there_is_a_genus "Pyramica"
    there_is_a_species "Strumigenys ravidura"

    i_go_to 'the catalog page for "Strumigenys ravidura"'
    i_follow "Create obsolete combination"
    i_pick_from_the_taxon_picker "Pyramica", "#obsolete_genus_id"
    i_press "Create!"
    i_should_be_on 'the catalog page for "Pyramica ravidura"'
    the_association_of_taxon_should_be "genus", "Pyramica ravidura", "Pyramica"

    i_go_to 'the activity feed'
    i_should_see "Archibald created the obsolete combination Pyramica ravidura", within: 'the activity feed'
  end
end
