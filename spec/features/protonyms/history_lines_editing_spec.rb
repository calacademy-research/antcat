# frozen_string_literal: true

require 'rails_helper'

# Editing history when a line holds many items (one per citation), as after the 2026 conversion of
# free-text history: editors move, and add before, whole lines (Bradley Reynolds, 23 Nov 2026).
feature "Editing grouped history lines", as: :editor do
  let(:protonym) { create :protonym, :species_group }
  let!(:note) { create :history_item, :taxt, protonym: protonym, taxt: "A note." }
  let!(:first_status) { create :history_item, :status_as_species, protonym: protonym }
  let!(:second_status) { create :history_item, :status_as_species, protonym: protonym }

  scenario "The reorder page has one row per line, and a grouped line moves as one piece" do
    visit protonym_reorder_history_items_path(protonym)

    rows = all("li[data-sortable-id]").map { |row| row["data-sortable-id"] }
    expect(rows.size).to eq 2
    expect(rows.first).to eq note.id.to_s
    expect(rows.second.split(",").map(&:to_i)).to contain_exactly(first_status.id, second_status.id)
    i_should_see "status_as_species x 2"

    # The hidden field holds every item id, so saving reorders (or keeps) all items.
    expect(find("input[name='new_order']", visible: :all).value.split(",").map(&:to_i)).
      to contain_exactly(note.id, first_status.id, second_status.id)
  end

  scenario "A grouped line has a link to add an item before the whole line" do
    visit protonym_path(protonym)

    link = find_link("Add item before this line")
    expect(link[:href]).to include "position=#{first_status.position}"

    # A single-item line keeps its own link, now for any type; items inside a group have none.
    expect(all(:link, "Add item before this", exact: true).size).to eq 1
  end

  scenario "The form for a new item has a citation note row of its own" do
    visit new_protonym_history_item_path(protonym)

    expect(page).to have_css "tr[data-history-item-form-target~='typeSpecificCitationNote']", visible: :all, count: 1
    expect(page).to have_css "tr[data-history-item-form-target~='typeSpecificPages']", visible: :all, count: 1
  end
end
