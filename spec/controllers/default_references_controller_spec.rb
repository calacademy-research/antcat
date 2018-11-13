require 'spec_helper'

describe DefaultReferencesController do
  describe "forbidden actions" do
    context "when not signed in" do
      specify { expect(post(:update, params: { id: 1 })).to redirect_to_signin_form }
    end
  end

  describe "POST update" do
    let(:reference) { create :article_reference }

    before do
      sign_in create(:user)
    end

    it "calls `DefaultReference.set`" do
      expect(DefaultReference).to receive(:set).with(session, reference).and_call_original
      post :update, params: { id: reference.id }
    end
  end
end
