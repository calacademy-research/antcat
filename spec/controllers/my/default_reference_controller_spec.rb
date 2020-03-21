require 'rails_helper'

describe My::DefaultReferenceController do
  describe "forbidden actions" do
    context "when not signed in" do
      specify { expect(put(:update, params: { id: 1 })).to redirect_to_signin_form }
    end
  end

  describe "PUT update", as: :user do
    let(:reference) { create :article_reference }

    it "calls `DefaultReference.set`" do
      expect(DefaultReference).to receive(:set).with(session, reference).and_call_original
      put :update, params: { id: reference.id }
    end
  end
end
