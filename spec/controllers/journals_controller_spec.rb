# frozen_string_literal: true

require 'rails_helper'

describe JournalsController do
  describe "forbidden actions" do
    context "when signed in as a user", as: :user do
      specify { expect(get(:edit, params: { id: 1 })).to have_http_status :forbidden }
      specify { expect(put(:update, params: { id: 1 })).to have_http_status :forbidden }
      specify { expect(delete(:destroy, params: { id: 1 })).to have_http_status :forbidden }
    end
  end

  describe "PUT update", as: :helper do
    let!(:journal) { create :journal, name: 'Science' }
    let(:journal_params) do
      {
        name: 'New name'
      }
    end

    it 'updates the journal' do
      put(:update, params: { id: journal.id, journal: journal_params })

      journal.reload
      expect(journal.name).to eq journal_params[:name]
    end

    it 'creates an activity' do
      expect { put(:update, params: { id: journal.id, journal: journal_params }) }.
        to change { Activity.where(action: Activity::UPDATE).count }.by(1)

      activity = Activity.last
      expect(activity.trackable).to eq journal
      expect(activity.parameters).to eq(name: 'New name', name_was: "Science")
    end

    context 'when journal has references' do
      let!(:reference) { create :article_reference, journal: journal }

      it 'calls `References::Cache::Invalidate`' do
        service_class = References::Cache::Invalidate
        allow(service_class).to receive(:[]).and_call_original

        put(:update, params: { id: journal.id, journal: journal_params })

        expect(service_class).to have_received(:[]).with([reference])
      end
    end
  end

  describe "DELETE destroy", as: :helper do
    let!(:journal) { create :journal }

    it 'deletes the journal' do
      expect { delete(:destroy, params: { id: journal.id }) }.to change { Journal.count }.by(-1)
    end

    it 'creates an activity' do
      expect { delete(:destroy, params: { id: journal.id }) }.
        to change { Activity.where(action: Activity::DESTROY, trackable: journal).count }.by(1)

      activity = Activity.last
      expect(activity.trackable_id).to eq journal.id
      expect(activity.parameters).to eq(name: journal.name, name_was: nil)
    end
  end
end
