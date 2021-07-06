# frozen_string_literal: true

require 'rails_helper'

describe Catalog::AutocompletesController, :search do
  describe "GET show", as: :visitor do
    let!(:taxon) { create :genus, name_string: "Atta" }

    before do
      Sunspot.commit
    end

    it "returns matches" do
      get :show, params: { q: "att", format: :json }

      expect(json_response).to eq [Autocomplete::TaxonSerializer.new(taxon).as_json].map(&:stringify_keys)
    end
  end
end
