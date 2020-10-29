# frozen_string_literal: true

require 'rails_helper'

describe HistoryItemsController do
  describe "forbidden actions" do
    context "when signed in as a user", as: :user do
      specify { expect(get(:new, params: { protonym_id: 1 })).to have_http_status :forbidden }
      specify { expect(get(:edit, params: { id: 1 })).to have_http_status :forbidden }
      specify { expect(post(:create, params: { protonym_id: 1 })).to have_http_status :forbidden }
      specify { expect(put(:update, params: { id: 1 })).to have_http_status :forbidden }
    end

    context "when signed in as a helper editor", as: :helper do
      specify { expect(delete(:destroy, params: { id: 1 })).to have_http_status :forbidden }
    end
  end

  describe "POST create", as: :helper do
    let!(:protonym) { create :protonym }
    let!(:history_item_params) do
      {
        taxt: 'content'
      }
    end

    it 'creates a history item' do
      expect do
        post(:create, params: { protonym_id: protonym.id, history_item: history_item_params })
      end.to change { HistoryItem.count }.by(1)

      history_item = HistoryItem.last
      expect(history_item.taxt).to eq history_item_params[:taxt]
    end

    it 'creates a activity' do
      expect do
        post(:create, params: { protonym_id: protonym.id, history_item: history_item_params, edit_summary: 'added' })
      end.to change { Activity.where(action: :create).count }.by(1)

      activity = Activity.last
      history_item = HistoryItem.last
      expect(activity.trackable).to eq history_item
      expect(activity.edit_summary).to eq "added"
      expect(activity.parameters).to eq(protonym_id: history_item.protonym_id)
    end
  end

  describe "PUT update", as: :helper do
    let!(:history_item) { create :history_item }
    let!(:history_item_params) do
      {
        taxt: 'content',
        rank: Rank::SUBFAMILY
      }
    end

    it 'updates the history item' do
      expect(history_item.taxt).to_not eq history_item_params[:taxt]
      expect(history_item.rank).to_not eq history_item_params[:rank]

      put(:update, params: { id: history_item.id, history_item: history_item_params })

      history_item.reload
      expect(history_item.taxt).to eq history_item_params[:taxt]
      expect(history_item.rank).to eq history_item_params[:rank]
    end

    it 'creates an activity' do
      expect do
        params = { id: history_item.id, history_item: history_item_params, edit_summary: 'Duplicate' }
        put :update, params: params
      end.to change { Activity.where(action: :update, trackable: history_item).count }.by(1)

      activity = Activity.last
      expect(activity.edit_summary).to eq "Duplicate"
      expect(activity.parameters).to eq(protonym_id: history_item.protonym_id)
    end
  end

  describe "DELETE destroy", as: :editor do
    let!(:history_item) { create :history_item }

    it 'deletes the history item' do
      expect { delete(:destroy, params: { id: history_item.id }) }.to change { HistoryItem.count }.by(-1)
    end

    it 'creates an activity' do
      expect { delete(:destroy, params: { id: history_item.id, edit_summary: 'Duplicate' }) }.
        to change { Activity.where(action: :destroy, trackable: history_item).count }.by(1)

      activity = Activity.last
      expect(activity.edit_summary).to eq "Duplicate"
      expect(activity.parameters).to eq(protonym_id: history_item.protonym_id)
    end
  end
end
