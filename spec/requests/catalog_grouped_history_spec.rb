# frozen_string_literal: true

require 'rails_helper'

# Editors see a "Show/hide grouped" toggle on grouped history lines. Types grouped by type alone
# (StatusAsSpecies, FormDescriptions) have a string group key; the page used to call `join` on it
# and returned a 500 for signed-in users (2026-11-08).
describe "Grouped history items on catalog pages" do
  let!(:species) { create :species }

  before do
    2.times { create :history_item, :status_as_species, protonym: species.protonym }
    2.times { create :history_item, :form_descriptions, protonym: species.protonym }
    2.times { create :history_item, :junior_synonym_of, protonym: species.protonym }
  end

  it "renders for visitors" do
    get catalog_path(species)
    expect(response).to have_http_status :ok
  end

  it "renders for signed-in users, with a toggle per group" do
    sign_in create(:user)
    get catalog_path(species)

    expect(response).to have_http_status :ok
    expect(response.body).to include 'data-toggler-target="grouped-StatusAsSpecies"'
    expect(response.body).to include 'data-toggler-target="grouped-FormDescriptions"'
  end
end
