# frozen_string_literal: true

require 'rails_helper'

describe Users::SessionsController do
  before do
    request.env["devise.mapping"] = Devise.mappings[:user]
  end

  describe "POST create", as: :visitor do
    let!(:user) { create :user, password: 'secret123', password_confirmation: 'secret123' }
    let(:sign_in_params) { { user: { email: user.email, password: 'secret123' } } }
    # Counters live in Rails.cache (a `NullStore` in tests), so stub `increment`.
    let(:rate_limit_store) { Rails.cache }

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

      it 'does not try the password' do
        warden = request.env['warden']
        allow(warden).to receive(:authenticate!).and_call_original

        post(:create, params: sign_in_params)

        expect(warden).not_to have_received(:authenticate!)
        expect(response).to redirect_to new_user_session_path
        expect(flash[:alert]).to eq described_class::TOO_MANY_ATTEMPTS_MESSAGE
      end
    end

    it 'counts attempts per IP and per email' do
      allow(rate_limit_store).to receive(:increment).and_call_original

      request.env['REMOTE_ADDR'] = '203.0.113.7'
      post(:create, params: { user: { email: " #{user.email.upcase} ", password: 'wrong' } })

      expect(rate_limit_store).to have_received(:increment).
        with(a_string_including('203.0.113.7'), any_args)
      expect(rate_limit_store).to have_received(:increment).
        with(a_string_including(user.email.downcase), any_args)
    end

    it 'does not trust a client-sent `CF-Connecting-IP` header (nginx sets the real IP)' do
      allow(rate_limit_store).to receive(:increment).and_call_original

      request.env['REMOTE_ADDR'] = '203.0.113.7'
      request.headers['CF-Connecting-IP'] = '198.51.100.9'
      post(:create, params: sign_in_params)

      expect(rate_limit_store).to have_received(:increment).with("sign_in:ip:203.0.113.7", any_args)
      expect(rate_limit_store).not_to have_received(:increment).with(a_string_including('198.51.100.9'), any_args)
    end
  end

  describe 'GET new', as: :visitor do
    it 'is not rate limited' do
      allow(Rails.cache).to receive(:increment)
      get :new
      expect(Rails.cache).not_to have_received(:increment)
    end
  end
end
