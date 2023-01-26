# frozen_string_literal: true

require 'rails_helper'

feature "What links here", %(
  As an editor of AntCat
  I want to see items linked to a taxon or reference
) do
  background do
    i_am_logged_in
    there_is_a_genus "Atta"
    there_is_a_genus_protonym "Eciton"

    eciton_has_a_history_item_that_references_atta_and_a_batiatus_reference
  end

  scenario "See related items (taxa, with detaxed taxt item)" do
    i_go_to 'the catalog page for "Atta"'
    i_follow "What Links Here"
    i_should_see "history_items"
    i_should_see "Protonym: Eciton"
    i_should_see "Atta: Batiatus"
  end

  scenario "See related items (references, with detaxed taxt item)" do
    i_go_to "the page of the most recent reference"
    i_follow "What Links Here"
    i_should_see "history_items"
    i_should_see "Protonym: Eciton"
    i_should_see "Atta: Batiatus"
  end
end
