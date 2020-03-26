# frozen_string_literal: true

require 'rails_helper'

describe My::RecentlyUsedReferencesController do
  describe "GET show", as: :visitor do
    let(:recently_used_references) { [] }

    it "calls `Autocomplete::FormatLinkableReferences`" do
      expect(Autocomplete::FormatLinkableReferences).
        to receive(:new).with(recently_used_references).and_call_original
      get :show
    end

    context 'when user has no recently used references' do
      it 'returns an empty JSON array' do
        get :show
        expect(json_response).to eq []
      end
    end

    context 'when user has recently used references' do
      let!(:reference) { create :article_reference }

      before do
        post :create, params: { id: reference.id }
      end

      it 'returns the references as a JSON array' do
        get :show
        expect(json_response).to eq Autocomplete::FormatLinkableReferences[[reference]].map(&:stringify_keys)
      end
    end
  end

  describe 'POST create', as: :visitor do
    let!(:reference) { create :article_reference }

    it "stores the reference in the user's session" do
      expect { post :create, params: { id: reference.id } }.
        to change { session[:recently_used_reference_ids] }.
        from(nil).to([reference.id.to_s])
    end

    describe 'adding multiple references' do
      let!(:second) { create :article_reference }
      let!(:third) { create :article_reference }

      it 'returns the the most recently used references first, unique only' do
        post :create, params: { id: reference.id }
        post :create, params: { id: second.id }
        post :create, params: { id: third.id }
        expect(session[:recently_used_reference_ids]).to eq [third.id.to_s, second.id.to_s, reference.id.to_s]

        post :create, params: { id: second.id }
        expect(session[:recently_used_reference_ids]).to eq [second.id.to_s, third.id.to_s, reference.id.to_s]
      end
    end
  end
end
