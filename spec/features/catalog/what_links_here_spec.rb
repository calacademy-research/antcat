# frozen_string_literal: true

require 'rails_helper'

feature "What links here", as: :user do
  background do
    atta = create :genus, name_string: "Atta"
    eciton = create :protonym, :genus_group, name: create(:genus_name, name: "Eciton")

    # Eciton has a history item referencing Atta and a Batiatus reference.
    reference = create :any_reference, author_string: 'Batiatus'
    create :history_item, :taxt, taxt: "#{Taxt.tax(atta.id)}: #{Taxt.ref(reference.id)}", protonym: eciton
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
