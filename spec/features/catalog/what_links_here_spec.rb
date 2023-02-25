# frozen_string_literal: true

require 'rails_helper'

feature "What links here", as: :user do
  scenario "See related items (taxa, with detaxed taxt item)" do
    taxon = create :genus, name_string: "Atta"
    protonym = create :protonym, :genus_group, protonym_name_string: "Eciton"
    create :history_item, :taxt, taxt: "#{Taxt.tax(taxon.id)} research", protonym: protonym

    visit catalog_path(taxon)

    i_follow "What Links Here"
    i_should_see "history_items"
    i_should_see "Protonym: Eciton"
    i_should_see "Atta research"
  end

  scenario "See related items (references, with detaxed taxt item)" do
    reference = create :any_reference, author_string: 'Batiatus'
    protonym = create :protonym, :genus_group, protonym_name_string: "Eciton"
    create :history_item, :taxt, taxt: "Research by #{Taxt.ref(reference.id)}", protonym: protonym

    visit reference_path(reference)
    i_follow "What Links Here"
    i_should_see "history_items"
    i_should_see "Protonym: Eciton"
    i_should_see "Research by Batiatus"
  end
end
