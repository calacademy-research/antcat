require 'spec_helper'

describe Taxa::ForceParentChangesController do
  describe "forbidden actions" do
    context "when signed in as a user" do
      before { sign_in create(:user) }

      specify { expect(get(:show, params: { taxa_id: 1 })).to have_http_status :forbidden }
      specify { expect(post(:create, params: { taxa_id: 1 })).to have_http_status :forbidden }
    end
  end

  describe "POST create" do
    let(:taxon) { create :tribe }
    let(:new_parent) { create :family }

    before { sign_in create(:user, :editor) }

    it "calls `Taxa::Operations::ForceParentChange`" do
      expect(Taxa::Operations::ForceParentChange).to receive(:new).with(taxon, new_parent).and_call_original
      post :create, params: { taxa_id: taxon.id, new_parent_id: new_parent.id }
    end
  end
end
