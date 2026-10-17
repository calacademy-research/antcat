# frozen_string_literal: true

require 'rails_helper'

describe Users::PasswordsController do
  before do
    request.env["devise.mapping"] = Devise.mappings[:user]
  end

  describe "POST create", as: :visitor do
    let!(:user) { create :user }
    # Counters live in Rails.cache (a `NullStore` in tests), so stub `increment`.
    let(:rate_limit_store) { Rails.cache }
    let(:paranoid_message) { I18n.t("devise.passwords.send_paranoid_instructions") }

    it 'sends reset instructions to an existing account' do
      expect { post(:create, params: { user: { email: user.email } }) }.
        to change { ActionMailer::Base.deliveries.count }.by(1)
      expect(response).to redirect_to new_user_session_path
      expect(flash[:notice]).to eq paranoid_message
    end

    it 'responds the same way for an email without an account' do
      expect { post(:create, params: { user: { email: 'nobody@example.com' } }) }.
        not_to change { ActionMailer::Base.deliveries.count }
      expect(response).to redirect_to new_user_session_path
      expect(flash[:notice]).to eq paranoid_message
    end

    it 'counts requests per IP and per email' do
      allow(rate_limit_store).to receive(:increment).and_call_original

      request.env['REMOTE_ADDR'] = '203.0.113.7'
      post(:create, params: { user: { email: " #{user.email.upcase} " } })

      expect(rate_limit_store).to have_received(:increment).with("password_reset:ip:203.0.113.7", any_args)
      expect(rate_limit_store).to have_received(:increment).
        with("password_reset:email:#{user.email.downcase}", any_args)
    end

    context 'when over the limit' do
      before do
        allow(rate_limit_store).to receive(:increment).and_return(described_class::RESET_REQUESTS_PER_IP + 1)
      end

      it 'does not send an email' do
        expect { post(:create, params: { user: { email: user.email } }) }.
          not_to change { ActionMailer::Base.deliveries.count }
        expect(response).to redirect_to new_user_password_path
        expect(flash[:alert]).to eq described_class::TOO_MANY_REQUESTS_MESSAGE
      end
    end
  end
end
