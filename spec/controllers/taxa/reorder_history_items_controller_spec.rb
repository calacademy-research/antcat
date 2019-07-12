require 'spec_helper'

describe Taxa::ReorderHistoryItemsController do
  describe "forbidden actions" do
    context "when signed in as a user" do
      before { sign_in create(:user) }

      specify { expect(post(:create, params: { taxa_id: 1 })).to have_http_status :forbidden }
    end
  end

  describe "POST create" do
    let(:taxon) { create :family }

    before { sign_in create(:user, :editor) }

    it "calls `Taxa::Operations::ReorderHistoryItems`" do
      expect(Taxa::Operations::ReorderHistoryItems).to receive(:new).with(taxon, ['1']).and_call_original
      post :create, params: { taxa_id: taxon.id, taxon_history_item: ['1'] }
    end
  end
end
