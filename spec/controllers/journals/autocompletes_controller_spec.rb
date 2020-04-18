# frozen_string_literal: true

require 'rails_helper'

describe Journals::AutocompletesController do
  describe "GET show", as: :visitor do
    let(:term) { "zoo" }

    it "calls `Autocomplete::JournalsQuery`" do
      expect(Autocomplete::JournalsQuery).to receive(:new).with(term).and_call_original
      get :show, params: { term: term, format: :json }
    end

    context 'when there are results' do
      let!(:zootaxa) { create :journal, name: 'Zootaxa' }
      let!(:zoological) { create :journal, name: 'Zoological Adventures' }

      before do
        create :journal, name: 'Science'
      end

      it 'returns an array of journal names' do
        get :show, params: { term: term, format: :json }
        expect(json_response).to match_array [zootaxa.name, zoological.name]
      end
    end
  end
end
