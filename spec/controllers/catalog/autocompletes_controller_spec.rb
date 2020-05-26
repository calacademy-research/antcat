# frozen_string_literal: true

require 'rails_helper'

describe Catalog::AutocompletesController do
  describe "GET show", as: :visitor do
    let!(:taxon) { create :genus, :fossil, name_string: "Ratta" }

    before do
      create :genus, name_string: "Nylanderia"
    end

    it "returns matches" do
      get :show, params: { q: "att", format: :json }

      expect(json_response).to eq(
        [
          {
            "id" => taxon.id,
            "plaintext_name" => "Ratta",
            "name_with_fossil" => "<i>†</i><i>Ratta</i>",
            "author_citation" => taxon.author_citation,
            "css_classes" => CatalogFormatter.disco_mode_css(taxon),
            "url" => "/catalog/#{taxon.id}"
          }
        ]
      )
    end
  end
end
