# frozen_string_literal: true

require 'rails_helper'

describe TaxonHistoryItemsController do
  describe "forbidden actions" do
    context "when signed in as a user", as: :user do
      specify { expect(get(:new, params: { taxa_id: 1 })).to have_http_status :forbidden }
      specify { expect(get(:edit, params: { id: 1 })).to have_http_status :forbidden }
      specify { expect(post(:create, params: { taxa_id: 1 })).to have_http_status :forbidden }
      specify { expect(put(:update, params: { id: 1 })).to have_http_status :forbidden }
    end

    context "when signed in as a helper editor", as: :helper do
      specify { expect(delete(:destroy, params: { id: 1 })).to have_http_status :forbidden }
    end
  end

  describe "POST create", as: :helper do
    let!(:taxon) { create :family }
    let!(:taxon_history_item_params) do
      {
        taxt: 'content'
      }
    end

    it 'creates a history item' do
      expect do
        post(:create, params: { taxa_id: taxon.id, taxon_history_item: taxon_history_item_params })
      end.to change { TaxonHistoryItem.count }.by(1)

      taxon_history_item = TaxonHistoryItem.last
      expect(taxon_history_item.taxt).to eq taxon_history_item_params[:taxt]
    end

    it 'creates a activity' do
      expect do
        post(:create, params: { taxa_id: taxon.id, taxon_history_item: taxon_history_item_params, edit_summary: 'added' })
      end.to change { Activity.where(action: :create).count }.by(1)

      activity = Activity.last
      taxon_history_item = TaxonHistoryItem.last
      expect(activity.trackable).to eq taxon_history_item
      expect(activity.edit_summary).to eq "added"
      expect(activity.parameters).to eq(taxon_id: taxon_history_item.taxon_id)
    end
  end

  describe "PUT update", as: :helper do
    let!(:taxon_history_item) { create :taxon_history_item }
    let!(:taxon_history_item_params) do
      {
        taxt: 'content',
        rank: 'Subfamily'
      }
    end

    it 'updates the history item' do
      expect(taxon_history_item.taxt).to_not eq taxon_history_item_params[:taxt]
      expect(taxon_history_item.rank).to_not eq taxon_history_item_params[:rank]

      put(:update, params: { id: taxon_history_item.id, taxon_history_item: taxon_history_item_params })

      taxon_history_item.reload
      expect(taxon_history_item.taxt).to eq taxon_history_item_params[:taxt]
      expect(taxon_history_item.rank).to eq taxon_history_item_params[:rank]
    end

    it 'creates an activity' do
      expect do
        params = { id: taxon_history_item.id, taxon_history_item: taxon_history_item_params, edit_summary: 'Duplicate' }
        put :update, params: params
      end.to change { Activity.where(action: :update, trackable: taxon_history_item).count }.by(1)

      activity = Activity.last
      expect(activity.edit_summary).to eq "Duplicate"
      expect(activity.parameters).to eq(taxon_id: taxon_history_item.taxon_id)
    end
  end

  describe "DELETE destroy", as: :editor do
    let!(:taxon_history_item) { create :taxon_history_item }

    it 'deletes the history item' do
      expect { delete(:destroy, params: { id: taxon_history_item.id }) }.to change { TaxonHistoryItem.count }.by(-1)
    end

    it 'creates an activity' do
      expect { delete(:destroy, params: { id: taxon_history_item.id, edit_summary: 'Duplicate' }) }.
        to change { Activity.where(action: :destroy, trackable: taxon_history_item).count }.by(1)

      activity = Activity.last
      expect(activity.edit_summary).to eq "Duplicate"
      expect(activity.parameters).to eq(taxon_id: taxon_history_item.taxon_id)
    end
  end
end
