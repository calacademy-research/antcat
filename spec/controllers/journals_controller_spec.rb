require 'spec_helper'

describe JournalsController do
  describe "forbidden actions" do
    context "when signed in as a user" do
      before { sign_in create(:user) }

      specify { expect(get(:edit, params: { id: 1 })).to have_http_status :forbidden }
      specify { expect(put(:update, params: { id: 1 })).to have_http_status :forbidden }
      specify { expect(delete(:destroy, params: { id: 1 })).to have_http_status :forbidden }
    end
  end

  describe "PUT update" do
    let!(:journal) { create :journal, name: 'Science' }
    let(:journal_params) do
      {
        name: 'New name'
      }
    end

    before { sign_in create(:user, :helper) }

    it 'updates the journal' do
      put(:update, params: { id: journal.id, journal: journal_params })

      journal.reload
      expect(journal.name).to eq journal_params[:name]
    end

    it 'creates an activity' do
      expect { put(:update, params: { id: journal.id, journal: journal_params }) }.
        to change { Activity.where(action: :update).count }.by(1)

      activity = Activity.last
      expect(activity.trackable).to eq journal
      expect(activity.parameters).to eq(name: 'New name', name_was: "Science")
    end

    context 'when journal has references' do
      let!(:reference) { create :article_reference, journal: journal }

      it 'invalidates reference caches' do
        expect(References::Cache::Invalidate).to receive(:new).with(reference).and_call_original
        put(:update, params: { id: journal.id, journal: journal_params })
      end
    end
  end

  describe "DELETE destroy" do
    let!(:journal) { create :journal }

    before { sign_in create(:user, :helper) }

    it 'deletes the journal' do
      expect { delete(:destroy, params: { id: journal.id }) }.to change { Journal.count }.by(-1)
    end

    it 'creates an activity' do
      expect { delete(:destroy, params: { id: journal.id }) }.
        to change { Activity.where(action: :destroy, trackable: journal).count }.by(1)

      activity = Activity.last
      expect(activity.trackable_id).to eq journal.id
      expect(activity.parameters).to eq(name: journal.name, name_was: nil)
    end
  end

  describe "GET autocomplete" do
    let(:term) { "zootaxa" }

    it "calls `Autocomplete::AutocompleteJournals`" do
      expect(Autocomplete::AutocompleteJournals).to receive(:new).with(term).and_call_original
      get :autocomplete, params: { term: term, format: :json }
    end
  end
end
