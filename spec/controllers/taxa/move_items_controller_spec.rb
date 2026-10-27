# frozen_string_literal: true

require 'rails_helper'

describe Taxa::MoveItemsController do
  describe "forbidden actions" do
    context "when signed in as a user", as: :user do
      specify { expect(get(:new, params: { taxon_id: 1 })).to have_http_status :forbidden }
      specify { expect(get(:show, params: { taxon_id: 1 })).to have_http_status :forbidden }
      specify { expect(post(:create, params: { taxon_id: 1 })).to have_http_status :forbidden }
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
        taxon_id: taxon.id,
        to_taxon_id: to_taxon.id,
        reference_section_ids: [reference_section.id]
      }

      post :create, params: params
    end

    it 'creates an activity' do
      expect do
        post :create,
          params: { taxon_id: taxon.id, to_taxon_id: to_taxon.id, reference_section_ids: [reference_section.id] }
      end.to change { Activity.where(event: Activity::MOVE_ITEMS, trackable: taxon).count }.by(1)

      activity = Activity.last
      expect(activity.parameters).to eq(to_taxon_id: to_taxon.id)
    end

    it "does not move reference sections that belong to another taxon" do
      other_section = create :reference_section, taxon: to_taxon

      post :create, params: { taxon_id: taxon.id, to_taxon_id: create(:any_taxon).id, reference_section_ids: [other_section.id] }

      expect(response).to have_http_status :unprocessable_content
      expect(other_section.reload.taxon).to eq to_taxon
    end

    it "redirects when the target is missing" do
      post :create, params: { taxon_id: taxon.id, reference_section_ids: [reference_section.id] }
      expect(response).to redirect_to new_taxon_move_items_path(taxon)
      expect(reference_section.reload.taxon).to eq taxon
    end
  end
end
