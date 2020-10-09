# frozen_string_literal: true

require 'rails_helper'

describe Protonyms::ReorderHistoryItemsController do
  describe "forbidden actions" do
    context "when signed in as a user", as: :user do
      specify { expect(post(:create, params: { protonym_id: 1 })).to have_http_status :forbidden }
    end
  end

  describe "POST create", as: :editor do
    let(:protonym) { create :protonym }
    let(:reordered_ids) { [second.id.to_s, first.id.to_s] }
    let!(:first) { protonym.protonym_history_items.create!(taxt: "A") }
    let!(:second) { protonym.protonym_history_items.create!(taxt: "B") }

    it "calls `Protonyms::Operations::ReorderHistoryItems`" do
      expect(Protonyms::Operations::ReorderHistoryItems).
        to receive(:new).with(protonym, reordered_ids).and_call_original
      post :create, params: { protonym_id: protonym.id, taxon_history_item: reordered_ids }
    end

    it "reorders the history items" do
      expect { post :create, params: { protonym_id: protonym.id, taxon_history_item: reordered_ids } }.
        to change { protonym.protonym_history_items.pluck(:id) }.to([second.id, first.id])
    end

    it 'creates an activity' do
      expect { post(:create, params: { protonym_id: protonym.id, taxon_history_item: reordered_ids }) }.
        to change { Activity.where(action: :reorder_protonym_history_items).count }.by(1)

      activity = Activity.last
      expect(activity.trackable).to eq protonym
    end
  end
end
