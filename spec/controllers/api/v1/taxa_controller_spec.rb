# frozen_string_literal: true

require 'rails_helper'

describe Api::V1::TaxaController, as: :visitor do
  describe "GET index" do
    specify do
      taxon = create :family
      get :index
      expect(json_response).to eq([Api::V1::TaxonSerializer.new(taxon).as_json])
    end

    specify { expect(get(:index)).to have_http_status :ok }
  end

  describe "GET show" do
    let!(:taxon) { create :species }

    specify do
      get :show, params: { id: taxon.id }
      expect(json_response).to eq Api::V1::TaxonSerializer.new(taxon).as_json
    end

    specify { expect(get(:show, params: { id: taxon.id })).to have_http_status :ok }
  end

  describe "GET search" do
    let!(:taxon) { create :species, name_string: 'Atta minor maxus' }

    specify do
      get :search, params: { string: 'maxus' }
      expect(json_response).to eq(
        [
          { "id" => taxon.id, "name" => taxon.name_cache }
        ]
      )
    end

    context "when there are no search matches" do
      it 'returns an empty array' do
        get :search, params: { string: 'pizza' }
        expect(json_response).to eq([])
      end
    end
  end
end
