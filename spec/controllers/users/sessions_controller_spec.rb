# frozen_string_literal: true

require 'rails_helper'

describe Users::SessionsController do
  before do
    request.env["devise.mapping"] = Devise.mappings[:user]
  end

  describe "POST create", as: :visitor do
    let!(:user) { create :user, password: 'secret123', password_confirmation: 'secret123' }
    let(:sign_in_params) { { user: { email: user.email, password: 'secret123' } } }
    # Rate limit counters live in the controller's cache store (a `NullStore` in tests).
    let(:rate_limit_store) { described_class.cache_store }

    it 'signs in the user' do
      post(:create, params: sign_in_params)
      expect(controller.current_user).to eq user
    end

    context 'when under the limit' do
      before do
        allow(rate_limit_store).to receive(:increment).and_return(described_class::SIGN_IN_ATTEMPTS_PER_IP)
      end

      it 'signs in the user' do
        post(:create, params: sign_in_params)
        expect(controller.current_user).to eq user
      end
    end

    context 'when over the limit' do
      before do
        allow(rate_limit_store).to receive(:increment).and_return(described_class::SIGN_IN_ATTEMPTS_PER_IP + 1)
      end

      it 'does not sign in the user' do
        post(:create, params: sign_in_params)

        # Not `current_user`: that would run Devise's params strategy again inside the test.
        expect(session["warden.user.user.key"]).to eq nil
        expect(response).to redirect_to new_user_session_path
        expect(flash[:alert]).to eq described_class::TOO_MANY_ATTEMPTS_MESSAGE
      end
    end

    it 'counts attempts per IP and per email' do
      allow(rate_limit_store).to receive(:increment).and_call_original

      request.headers['CF-Connecting-IP'] = '203.0.113.7'
      post(:create, params: { user: { email: " #{user.email.upcase} ", password: 'wrong' } })

      expect(rate_limit_store).to have_received(:increment).
        with(a_string_including('203.0.113.7'), any_args)
      expect(rate_limit_store).to have_received(:increment).
        with(a_string_including(user.email.downcase), any_args)
    end
  end

  describe 'GET new', as: :visitor do
    it 'is not rate limited' do
      allow(described_class.cache_store).to receive(:increment)
      get :new
      expect(described_class.cache_store).not_to have_received(:increment)
    end
  end
end
