# frozen_string_literal: true

require 'rails_helper'

describe Protonyms::ReorderHistoryItemsController do
  describe "forbidden actions" do
    context "when signed in as a user", as: :user do
      specify { expect(post(:show, params: { protonym_id: 1 })).to have_http_status :forbidden }
      specify { expect(post(:create, params: { protonym_id: 1 })).to have_http_status :forbidden }
    end
  end

  describe "GET show", as: :editor do
    let(:protonym) { create :protonym }

    specify { expect(get(:show, params: { protonym_id: protonym.id })).to render_template :show }
  end

  describe "POST create", as: :editor do
    let(:protonym) { create :protonym }

    let(:reordered_ids) { [second.id.to_s, first.id.to_s] }
    let(:new_order) { [second.id, first.id].join(',') }

    let!(:first) { protonym.history_items.create!(taxt: "A") }
    let!(:second) { protonym.history_items.create!(taxt: "B") }

    it "calls `Protonyms::Operations::ReorderHistoryItems`" do
      expect(Protonyms::Operations::ReorderHistoryItems).
        to receive(:new).with(protonym, reordered_ids).and_call_original
      post :create, params: { protonym_id: protonym.id, new_order: new_order }
    end

    it "reorders the history items" do
      expect { post :create, params: { protonym_id: protonym.id, new_order: new_order } }.
        to change { protonym.history_items.pluck(:id) }.to([second.id, first.id])
    end

    it 'creates an activity' do
      expect { post(:create, params: { protonym_id: protonym.id, new_order: new_order }) }.
        to change { Activity.where(action: Activity::REORDER_HISTORY_ITEMS).count }.by(1)

      activity = Activity.last
      expect(activity.trackable).to eq protonym
    end
  end
end
