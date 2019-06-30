require 'spec_helper'

describe CatalogController do
  describe "GET autocomplete" do
    let!(:atta) { create :genus, name_string: "Atta" }
    let!(:ratta) { create :genus, name_string: "Ratta" }

    before do
      create :genus, name_string: "Nylanderia"
      get :autocomplete, params: { q: "att", format: :json }
    end

    it "returns matches" do
      results = json_response.map { |taxon| taxon["id"] }
      expect(results).to eq [atta.id, ratta.id]
    end
  end
end
