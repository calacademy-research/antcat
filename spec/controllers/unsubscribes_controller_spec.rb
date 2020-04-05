# frozen_string_literal: true

require 'rails_helper'

describe UnsubscribesController do
  describe "GET show", as: :visitor do
    context "when token is valid" do
      let(:user) { create :user }
      let(:token) { valid_token(user) }

      specify { expect(get(:show, params: { token: token })).to render_template :show }
    end

    context "when token is not valid" do
      let(:token) { 'pizza' }

      it "updates the user's settings" do
        get :show, params: { token: token }

        expect(response).to redirect_to root_path
        expect(response.request.flash[:alert]).to eq "Token invalid. Unable to unsubscribe. Email us?"
      end
    end
  end

  describe "POST create", as: :visitor do
    context "when token is valid" do
      let(:user) { create :user }
      let(:token) { valid_token(user) }

      it "updates the user's settings" do
        expect { post :create, params: { token: token } }.
          to change { user.reload.enable_email_notifications }.to(false)
      end
    end

    context "when token is not valid" do
      let(:token) { 'pizza' }

      it "updates the user's settings" do
        post :create, params: { token: token }

        expect(response).to redirect_to root_path
        expect(response.request.flash[:alert]).to eq "Token invalid. Unable to unsubscribe. Email us?"
      end
    end
  end

  def valid_token user
    Rails.application.message_verifier(ApplicationMailer::UNSUBSCRIBE_VERIFIER_KEY).generate(user.id)
  end
end
