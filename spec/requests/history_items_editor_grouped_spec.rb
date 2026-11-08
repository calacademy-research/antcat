# frozen_string_literal: true

require 'rails_helper'

# Signed-in views of history items group them as the catalog page does: one block per displayed line,
# with a toggle showing the items of a grouped line (2026-11-08, after the free-text status lines
# became one item per citation).
describe "Grouped history items in editor views" do
  let!(:species) { create :species }
  let(:protonym) { species.protonym }

  before do
    3.times { create :history_item, :status_as_species, protonym: protonym }
    create :history_item, :taxt, protonym: protonym, taxt: "A free-text line"
  end

  describe "protonym page, history items box" do
    before { sign_in create(:user, :helper) }

    it "shows one grouped line with a toggle, and the items inside it" do
      get protonym_path(protonym)

      expect(response).to have_http_status :ok
      expect(response.body.scan('Show/hide grouped').size).to eq 1
      expect(response.body).to match(/data-toggler-target=['"]grouped-StatusAsSpecies['"]/)
      expect(response.body).to include 'status_as_species x 3'
      expect(response.body).to include 'A free-text line'
      expect(response.body).to include 'history-item taxt-history-item'
      expect(response.body).to include 'history-item status_as_species-history-item'
    end
  end

  describe "catalog page of an obsolete combination, protonym items not shown on the page" do
    let!(:obsolete_combination) do
      create :species, :obsolete_combination, protonym: protonym, current_taxon: species
    end

    before { sign_in create(:user) }

    it "lists the grouped lines, not one line per item" do
      get catalog_path(obsolete_combination)

      expect(response).to have_http_status :ok
      expect(response.body).to include 'Protonym history items not shown on this page'
      expect(response.body.scan('Status as species:').size).to eq 1
    end
  end
end
