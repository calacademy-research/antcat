require 'rails_helper'

describe Taxa::ReorderReferenceSectionsController do
  describe "forbidden actions" do
    context "when signed in as a user" do
      before { sign_in create(:user) }

      specify { expect(post(:create, params: { taxa_id: 1 })).to have_http_status :forbidden }
    end
  end

  describe "POST create" do
    let(:taxon) { create :family }
    let(:reordered_ids) { [second.id.to_s, first.id.to_s] }
    let!(:first) { taxon.reference_sections.create! }
    let!(:second) { taxon.reference_sections.create! }

    before { sign_in create(:user, :editor) }

    it "calls `Taxa::Operations::ReorderReferenceSections`" do
      expect(Taxa::Operations::ReorderReferenceSections).to receive(:new).with(taxon, reordered_ids).and_call_original
      post :create, params: { taxa_id: taxon.id, reference_section: reordered_ids }
    end

    it "reorders the reference sections" do
      expect { post :create, params: { taxa_id: taxon.id, reference_section: reordered_ids } }.
        to change { taxon.reference_sections.pluck(:id) }.to([second.id, first.id])
    end

    it 'creates an activity' do
      expect { post(:create, params: { taxa_id: taxon.id, reference_section: reordered_ids }) }.
        to change { Activity.where(action: :reorder_reference_sections).count }.by(1)

      activity = Activity.last
      expect(activity.trackable).to eq taxon
    end
  end
end
