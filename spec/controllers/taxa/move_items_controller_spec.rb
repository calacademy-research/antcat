# frozen_string_literal: true

require 'rails_helper'

describe Taxa::MoveItemsController do
  describe "forbidden actions" do
    context "when signed in as a user", as: :user do
      specify { expect(get(:new, params: { taxa_id: 1 })).to have_http_status :forbidden }
      specify { expect(get(:show, params: { taxa_id: 1 })).to have_http_status :forbidden }
      specify { expect(post(:create, params: { taxa_id: 1 })).to have_http_status :forbidden }
    end
  end

  describe "POST create", as: :editor do
    let!(:taxon) { create :any_taxon }
    let!(:reference_section) { create :reference_section, taxon: taxon }
    let!(:to_taxon) { create :any_taxon }

    it "calls `Taxa::Operations::MoveItems`" do
      expect(Taxa::Operations::MoveItems).to receive(:new).with(
        to_taxon,
        reference_sections: [reference_section]
      ).and_call_original

      params = {
        taxa_id: taxon.id,
        to_taxon_id: to_taxon.id,
        reference_section_ids: [reference_section.id]
      }

      post :create, params: params
    end

    it 'creates an activity' do
      expect { post :create, params: { taxa_id: taxon.id, to_taxon_id: to_taxon.id, reference_section_ids: [reference_section.id] } }.
        to change { Activity.where(action: :move_items, trackable: taxon).count }.by(1)

      activity = Activity.last
      expect(activity.parameters).to eq(to_taxon_id: to_taxon.id)
    end
  end
end
