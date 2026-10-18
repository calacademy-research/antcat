# frozen_string_literal: true

require 'rails_helper'

describe "API and search limits" do
  describe "CORS" do
    let!(:taxon) { create :species }

    it "allows cross-origin reads of the API" do
      get "/v1/taxa/#{taxon.id}", headers: { 'Origin' => 'https://example.org' }

      expect(response).to have_http_status :ok
      expect(response.headers['Access-Control-Allow-Origin']).to eq '*'
    end

    it "does not allow cross-origin requests to other pages" do
      get catalog_path(taxon), headers: { 'Origin' => 'https://example.org' }
      expect(response.headers['Access-Control-Allow-Origin']).to be_nil

      process :options, "/catalog/search", headers: {
        'Origin' => 'https://example.org', 'Access-Control-Request-Method' => 'POST'
      }
      expect(response.headers['Access-Control-Allow-Origin']).to be_nil
    end

    it "does not allow cross-origin POSTs to the API" do
      process :options, "/v1/taxa/#{taxon.id}", headers: {
        'Origin' => 'https://example.org', 'Access-Control-Request-Method' => 'POST'
      }
      expect(response.headers['Access-Control-Allow-Methods'].to_s).not_to include 'POST'
    end
  end

  describe "GET /v1/taxa/search/:string" do
    let!(:atta) { create :species, name_string: 'Atta minor' }

    before do
      create :species, name_string: 'Lasius niger'
      Api::V1::TaxaController::SEARCH_RATE_LIMIT_STORE.clear
    end

    def search string
      get "/v1/taxa/search/#{ERB::Util.url_encode(string)}"
    end

    it "finds taxa by part of the name" do
      search 'minor'
      expect(response.parsed_body).to eq [{ "id" => atta.id, "name" => atta.name_cache }]
    end

    it "treats % and _ as plain characters" do
      search '%'
      expect(response.parsed_body).to eq []

      search 'Att_'
      expect(response.parsed_body).to eq []
    end

    it "needs at least 2 characters" do
      search 'a'
      expect(response).to have_http_status :ok
      expect(response.parsed_body).to eq []
    end

    it "limits the number of requests per visitor" do
      Api::V1::TaxaController::SEARCH_REQUESTS_PER_MINUTE.times { search 'minor' }
      expect(response).to have_http_status :ok

      search 'minor'
      expect(response).to have_http_status :too_many_requests
    end
  end

  describe "the exact-match notice of the catalog search" do
    let!(:taxon) { create :species, name_string: 'Lasius niger' }

    it "encodes the search text in the link" do
      get "/catalog/search", params: { qq: 'Lasius niger', Catalog::SearchesController::SEARCHING_FROM_HEADER => 'y' }

      expect(response).to redirect_to catalog_path(taxon, qq: 'Lasius niger')
      expect(flash[:notice]).to include "href='/catalog/search?qq=Lasius%20niger'"

      follow_redirect!
      expect(response.body).to include 'href="/catalog/search?qq=Lasius%20niger"'
    end
  end
end
