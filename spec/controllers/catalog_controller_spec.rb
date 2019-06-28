require 'spec_helper'

describe CatalogController do
  describe "GET autocomplete" do
    let!(:atta) { create_genus "Atta" }
    let!(:ratta) { create_genus "Ratta" }

    before do
      create_genus "Nylanderia"
      get :autocomplete, params: { q: "att", format: :json }
    end

    it "returns matches" do
      results = json_response.map { |taxon| taxon["id"] }
      expect(results).to eq [atta.id, ratta.id]
    end
  end
end
