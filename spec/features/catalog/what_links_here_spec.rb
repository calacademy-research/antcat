# frozen_string_literal: true

require 'rails_helper'

feature "What links here", as: :user do
  background do
    @taxon = atta = create :genus, name_string: "Atta"
    eciton = create :protonym, :genus_group, protonym_name_string: "Eciton"

    # Eciton has a history item referencing Atta and a Batiatus reference.
    reference = create :any_reference, author_string: 'Batiatus'
    create :history_item, :taxt, taxt: "#{Taxt.tax(atta.id)} book by #{Taxt.ref(reference.id)}", protonym: eciton
  end

  scenario "See related items (taxa, with detaxed taxt item)" do
    visit catalog_path(@taxon)

    i_follow "What Links Here"
    i_should_see "history_items"
    i_should_see "Protonym: Eciton"
    i_should_see "Atta book by Batiatus"
  end

  scenario "See related items (references, with detaxed taxt item)" do
    visit reference_path(Reference.last)
    i_follow "What Links Here"
    i_should_see "history_items"
    i_should_see "Protonym: Eciton"
    i_should_see "Atta book by Batiatus"
  end
end
