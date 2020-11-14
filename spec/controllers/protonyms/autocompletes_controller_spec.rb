# frozen_string_literal: true

require 'rails_helper'

describe Protonyms::AutocompletesController, :search do
  describe "GET show", as: :visitor do
    it "calls `Autocomplete::ProtonymsQuery`" do
      expect(Autocomplete::ProtonymsQuery).to receive(:new).
        with("lasius", per_page: described_class::NUM_RESULTS).and_call_original
      get :show, params: { qq: "lasius", format: :json }
    end

    it "trims leading whitespace from search queries" do
      expect(Autocomplete::ProtonymsQuery).to receive(:new).
        with("lasius  ", per_page: described_class::NUM_RESULTS).and_call_original
      get :show, params: { qq: "  lasius  ", format: :json }
    end

    describe 'fulltext search' do
      let!(:protonym) { create :protonym, :fossil, name: create(:genus_name, name: 'Lasius') }

      specify do
        Sunspot.commit

        get :show, params: { qq: 'las', format: :json }
        expect(json_response).to eq Autocomplete::ProtonymsSerializer[[protonym]].map(&:stringify_keys)
      end
    end
  end
end
