# frozen_string_literal: true

require 'rails_helper'

describe References::LinkableAutocompletesController do
  describe "GET show", as: :visitor do
    let(:q) { "bolton" }

    it "calls `Autocomplete::AutocompleteLinkableReferences`" do
      expect(Autocomplete::AutocompleteLinkableReferences).to receive(:new).with(q).and_call_original
      get :show, params: { q: q, format: :json }
    end

    context "when there are results", :search do
      let!(:reference) { create :any_reference, author_string: "Bolton" }

      before { Sunspot.commit }

      specify do
        get :show, params: { q: "Bolton", format: :json }
        expect(json_response).to eq Autocomplete::FormatLinkableReferences[[reference]].map(&:stringify_keys)
      end
    end

    context 'when a reference ID is given' do
      let!(:reference) { create :any_reference }

      specify do
        get :show, params: { q: reference.id.to_s, format: :json }
        expect(json_response).to eq Autocomplete::FormatLinkableReferences[[reference]].map(&:stringify_keys)
      end
    end
  end
end
