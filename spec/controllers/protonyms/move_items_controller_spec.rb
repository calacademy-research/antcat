# frozen_string_literal: true

require 'rails_helper'

describe Protonyms::MoveItemsController do
  describe "forbidden actions" do
    context "when signed in as a user", as: :user do
      specify { expect(get(:new, params: { protonym_id: 1 })).to have_http_status :forbidden }
      specify { expect(get(:show, params: { protonym_id: 1 })).to have_http_status :forbidden }
      specify { expect(post(:create, params: { protonym_id: 1 })).to have_http_status :forbidden }
    end
  end

  describe "POST create", as: :editor do
    let!(:protonym) { create :protonym }
    let!(:history_item) { create :history_item, :taxt, protonym: protonym }
    let!(:to_protonym) { create :protonym }

    it "calls `Protonyms::Operations::MoveItems`" do
      expect(Protonyms::Operations::MoveItems).to receive(:new).with(
        to_protonym,
        history_items: [history_item]
      ).and_call_original

      params = {
        protonym_id: protonym.id,
        to_protonym_id: to_protonym.id,
        history_item_ids: [history_item.id]
      }

      post :create, params: params
    end

    it 'creates an activity' do
      params = {
        protonym_id: protonym.id,
        to_protonym_id: to_protonym.id,
        history_item_ids: [history_item.id]
      }

      expect { post :create, params: params }.
        to change { Activity.where(event: Activity::MOVE_PROTONYM_ITEMS, trackable: protonym).count }.by(1)

      activity = Activity.last
      expect(activity.parameters).to eq(to_protonym_id: to_protonym.id)
    end

    it "does not move items that belong to another protonym" do
      other_item = create :history_item, :taxt, protonym: to_protonym

      post :create, params: { protonym_id: protonym.id, to_protonym_id: create(:protonym).id, history_item_ids: [other_item.id] }

      expect(response).to have_http_status :unprocessable_content
      expect(other_item.reload.protonym).to eq to_protonym
    end

    it "redirects when the target is missing or the same protonym" do
      post :create, params: { protonym_id: protonym.id, history_item_ids: [history_item.id] }
      expect(response).to redirect_to new_protonym_move_items_path(protonym)

      post :create, params: { protonym_id: protonym.id, to_protonym_id: protonym.id, history_item_ids: [history_item.id] }
      expect(response).to redirect_to new_protonym_move_items_path(protonym)
      expect(history_item.reload.protonym).to eq protonym
    end
  end
end
