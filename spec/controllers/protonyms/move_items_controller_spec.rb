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
    let!(:history_item) { create :history_item, protonym: protonym }
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
        to change { Activity.where(action: Activity::MOVE_PROTONYM_ITEMS, trackable: protonym).count }.by(1)

      activity = Activity.last
      expect(activity.parameters).to eq(to_protonym_id: to_protonym.id)
    end
  end
end
