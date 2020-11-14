# frozen_string_literal: true

require 'rails_helper'

describe Catalog::AutocompletesController, :search do
  describe "GET show", as: :visitor do
    let!(:taxon) { create :genus, :fossil, name_string: "Atta" }

    before do
      Sunspot.commit
    end

    it "returns matches" do
      get :show, params: { q: "att", format: :json }

      expect(json_response).to eq(
        [
          {
            "id" => taxon.id,
            "plaintext_name" => taxon.name_cache,
            "name_with_fossil" => "<i>†</i><i>#{taxon.name_cache}</i>",
            "author_citation" => taxon.author_citation,
            "css_classes" => CatalogFormatter.taxon_disco_mode_css(taxon),
            "url" => "/catalog/#{taxon.id}"
          }
        ]
      )
    end
  end
end
