require 'spec_helper'

describe My::RecentlyUsedReferencesController do
  describe "GET index" do
    let(:recently_used_references) { [] }

    it "calls `Autocomplete::FormatLinkableReferences`" do
      expect(Autocomplete::FormatLinkableReferences).
        to receive(:new).with(recently_used_references).and_call_original
      get :index
    end

    context 'when user has no recently used references' do
      it 'returns an empty JSON array' do
        get :index
        expect(json_response).to eq []
      end
    end

    context 'when user has recently used references' do
      let!(:reference) { create :reference }

      before do
        post :create, params: { id: reference.id }
      end

      it 'returns the references as a JSON array' do
        get :index
        expect(json_response).to eq(
          [
            {
              "id" => reference.id,
              "author" => "",
              "year" => reference.citation_year,
              "title" => reference.title + '.',
              "full_pagination" => "",
              "bolton_key" => ""
            }
          ]
        )
      end
    end
  end

  describe 'POST create' do
    let!(:reference) { create :reference }

    it "stores the reference in the user's session" do
      expect { post :create, params: { id: reference.id } }.
        to change { session[:recently_used_reference_ids] }.
        from(nil).to([reference.id.to_s])
    end

    describe 'adding multiple references' do
      let!(:second) { create :reference }
      let!(:third) { create :reference }

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
