# frozen_string_literal: true

require 'rails_helper'

# Hidden editor notes (`{hiddennote ...}`) and reference editor/taxonomic notes are for signed-in users.
# For visitors they must not be in the page source or in the (open) API at all, not just hidden by CSS.
describe "Logged-in only content" do
  let(:note) { "secret editorial remark" }
  let(:hidden_note) { "{#{Taxt::HIDDENNOTE_TAG} #{note}}" }

  describe "hidden editor notes on catalog pages" do
    let!(:species) { create :species }

    before { species.protonym.update!(notes_taxt: "Visible text #{hidden_note}") }

    it "leaves them out of the HTML for visitors" do
      get catalog_path(species)

      expect(response).to have_http_status :ok
      expect(response.body).to include "Visible text"
      expect(response.body).not_to include note
      expect(response.body).not_to include "Hidden editor note"
    end

    it "shows them to signed-in users" do
      sign_in create(:user)
      get catalog_path(species)

      expect(response.body).to include "<b>Hidden editor note:</b> #{note}"
    end
  end

  describe "the API" do
    let!(:history_item) { create :history_item, :taxt, taxt: "Item #{hidden_note}" }
    let!(:reference_section) { create :reference_section, references_taxt: "Refs #{hidden_note}" }

    before { history_item.protonym.update!(notes_taxt: "Notes #{hidden_note}") }

    it "removes hidden notes from taxt fields" do
      get "/v1/history_items/#{history_item.id}"
      expect(response.parsed_body.dig("history_item", "taxt")).to eq "Item"

      get "/v1/history_items"
      expect(response.body).not_to include note

      get "/v1/protonyms/#{history_item.protonym.id}"
      expect(response.parsed_body.dig("protonym", "notes_taxt")).to eq "Notes"

      get "/v1/protonyms"
      expect(response.body).not_to include note

      get "/v1/reference_sections/#{reference_section.id}"
      expect(response.parsed_body.dig("reference_section", "references_taxt")).to eq "Refs"

      get "/v1/reference_sections"
      expect(response.body).not_to include note
    end

    it "removes hidden notes for signed-in users too (the API output does not depend on the session)" do
      sign_in create(:user)
      get "/v1/history_items/#{history_item.id}"

      expect(response.body).not_to include note
    end

    it "does not include reference editor or taxonomic notes" do
      reference = create :any_reference, editor_notes: "editor #{note}", taxonomic_notes: "taxonomic #{note}"

      get "/v1/references/#{reference.id}"
      expect(response).to have_http_status :ok
      expect(response.body).not_to include note

      get "/v1/references"
      expect(response.body).not_to include note
    end
  end

  describe "reference pages and exports" do
    let!(:reference) do
      create :article_reference, editor_notes: "editor #{note}", taxonomic_notes: "taxonomic #{note}"
    end

    it "does not show editor or taxonomic notes to visitors" do
      get reference_path(reference)
      expect(response.body).not_to include note

      get "/references/#{reference.id}/history"
      expect(response).to have_http_status :ok
      expect(response.body).not_to include note

      get "/references/exports/endnote", params: { id: reference.id }
      expect(response.body).not_to include note
    end

    it "shows them to signed-in users" do
      sign_in create(:user)

      get reference_path(reference)
      expect(response.body).to include "editor #{note}"

      get "/references/exports/endnote", params: { id: reference.id }
      expect(response.body).to include "taxonomic #{note}"
    end
  end

  describe "reference search", :search do
    let!(:reference) { create :any_reference, editor_notes: "zymurgical", taxonomic_notes: "quixotical" }

    before { Sunspot.commit }

    it "does not match words in editor or taxonomic notes for visitors" do
      %w[zymurgical quixotical].each do |word|
        get "/references/search", params: { reference_q: word }
        expect(response.body).not_to include reference_path(reference)

        get "/references/autocomplete.json", params: { reference_q: word }
        expect(response.parsed_body).to eq []
      end
    end

    it "matches them for signed-in users" do
      sign_in create(:user)

      get "/references/search", params: { reference_q: "zymurgical" }
      expect(response.body).to include reference_path(reference)
    end
  end

  describe "revision histories", :versioning do
    let!(:history_item) { create :history_item, :taxt, taxt: "First #{hidden_note}" }

    before { history_item.update!(taxt: "Second #{hidden_note}") }

    it "leaves hidden notes out for visitors" do
      get "/history_items/#{history_item.id}/history"
      expect(response).to have_http_status :ok
      expect(response.body).not_to include note

      get "/history_items/#{history_item.id}"
      expect(response).to have_http_status :ok
      expect(response.body).not_to include note
    end
  end
end
