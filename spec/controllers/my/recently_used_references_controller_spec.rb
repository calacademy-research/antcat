# frozen_string_literal: true

require 'rails_helper'

describe My::RecentlyUsedReferencesController do
  describe "GET show", as: :visitor do
    let(:recently_used_references) { [] }

    it "calls `Autocomplete::LinkableReferencesSerializer`" do
      expect(Autocomplete::LinkableReferencesSerializer).
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
      let!(:reference) { create :any_reference }

      before do
        post :create, params: { id: reference.id }
      end

      it 'returns the references as a JSON array' do
        get :show
        expect(json_response).to eq Autocomplete::LinkableReferencesSerializer[[reference]].map(&:stringify_keys)
      end

      context 'when a stored reference has been deleted' do
        let!(:deleted_reference) { create :any_reference }

        before do
          post :create, params: { id: deleted_reference.id }
          deleted_reference.destroy!
        end

        it 'returns the remaining references' do
          get :show
          expect(response).to have_http_status :ok
          expect(json_response).to eq Autocomplete::LinkableReferencesSerializer[[reference]].map(&:stringify_keys)
        end
      end
    end
  end

  describe 'POST create', as: :visitor do
    let!(:reference) { create :any_reference }

    it "stores the reference in the user's session" do
      expect { post :create, params: { id: reference.id } }.
        to change { session[:recently_used_reference_ids] }.
        from(nil).to([reference.id])
    end

    it 'ignores a missing or unknown ID' do
      post :create, params: { id: reference.id }
      post :create
      post :create, params: { id: 'abc' }
      post :create, params: { id: reference.id + 1000 }

      expect(session[:recently_used_reference_ids]).to eq [reference.id]
      get :show
      expect(response).to have_http_status :ok
    end

    describe 'adding multiple references' do
      let!(:second) { create :any_reference }
      let!(:third) { create :any_reference }

      it 'returns the most recently used references first, unique only' do
        post :create, params: { id: reference.id }
        post :create, params: { id: second.id }
        post :create, params: { id: third.id }
        expect(session[:recently_used_reference_ids]).to eq [third.id, second.id, reference.id]

        post :create, params: { id: second.id }
        expect(session[:recently_used_reference_ids]).to eq [second.id, third.id, reference.id]
      end
    end
  end
end
