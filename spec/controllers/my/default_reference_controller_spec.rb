# frozen_string_literal: true

require 'rails_helper'

describe My::DefaultReferenceController do
  describe "forbidden actions", as: :visitor do
    context "when not signed in" do
      specify { expect(put(:update, params: { id: 1 })).to redirect_to_signin_form }
    end
  end

  describe "PUT update", as: :user do
    let(:reference) { create :any_reference }

    it "calls `References::DefaultReference.set`" do
      expect(References::DefaultReference).to receive(:set).with(session, reference).and_call_original
      put :update, params: { id: reference.id }
    end
  end
end
