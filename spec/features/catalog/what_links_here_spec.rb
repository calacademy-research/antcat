# frozen_string_literal: true

require 'rails_helper'

feature "What links here", as: :user do
  def eciton_has_a_history_item_that_references_atta_and_a_batiatus_reference
    eciton = Protonym.joins(:name).find_by!(names: { name: "Eciton" })
    atta = Taxon.find_by!(name_cache: "Atta")
    reference = create :any_reference, author_string: 'Batiatus'

    create :history_item, :taxt, taxt: "#{Taxt.tax(atta.id)}: #{Taxt.ref(reference.id)}", protonym: eciton
  end

  background do
    create :genus, name_string: "Atta"
    create :protonym, :genus_group, name: create(:genus_name, name: "Eciton")

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
