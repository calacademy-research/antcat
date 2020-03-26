require 'rails_helper'

describe Catalog::AutocompletesController do
  describe "GET show", as: :visitor do
    let!(:atta) { create :genus, name_string: "Atta" }
    let!(:ratta) { create :genus, name_string: "Ratta" }

    before do
      create :genus, name_string: "Nylanderia"
    end

    it "returns matches" do
      get :show, params: { q: "att", format: :json }

      results = json_response.map { |taxon| taxon["id"] }
      expect(results).to eq [atta.id, ratta.id]
    end
  end
end
