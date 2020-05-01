# frozen_string_literal: true

require 'rails_helper'

describe Catalog::AutocompletesController do
  describe "GET show", as: :visitor do
    let!(:taxon) { create :genus, name_string: "Ratta" }

    before do
      create :genus, name_string: "Nylanderia"
    end

    it "returns matches" do
      get :show, params: { q: "att", format: :json }

      expect(json_response).to eq(
        [
          {
            "id" => taxon.id,
            "name" => taxon.name_cache,
            "name_html" => taxon.name_html_cache,
            "name_with_fossil" => taxon.name_with_fossil,
            "author_citation" => taxon.author_citation,
            "url" => "/catalog/#{taxon.id}"
          }
        ]
      )
    end
  end
end
