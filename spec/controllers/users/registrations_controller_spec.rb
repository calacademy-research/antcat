# frozen_string_literal: true

require 'rails_helper'

describe Users::RegistrationsController do
  # To fix:
  #   Could not find devise mapping for path "/users".
  #   ...
  #   2) You are testing a Devise controller bypassing the router.
  #      If so, you can explicitly tell Devise which mapping to use ...
  before do
    request.env["devise.mapping"] = Devise.mappings[:user]
  end

  describe "POST create", as: :visitor do
    let!(:user_params) do
      {
        email: 'pizza@example.com',
        name: 'Quintus Batiatus'
      }
    end

    # The sign-up flow itself is in spec/requests/users/sign_up_spec.rb.
    it 'does not create a user (that happens after the emailed link)' do
      expect { post(:create, params: { user: user_params }) }.not_to change { User.count }
      expect(response).to redirect_to root_path
    end

    describe 'throttling' do
      # Counters live in Rails.cache (a `NullStore` in tests), so stub `increment`.
      let(:rate_limit_store) { Rails.cache }

      it 'counts sign-ups per IP and per email' do
        allow(rate_limit_store).to receive(:increment).and_call_original

        request.env['REMOTE_ADDR'] = '203.0.113.7'
        post(:create, params: { user: user_params })

        expect(rate_limit_store).to have_received(:increment).with("sign_up:ip:203.0.113.7", any_args)
        expect(rate_limit_store).to have_received(:increment).with("sign_up:email:pizza@example.com", any_args)
      end

      context 'when over the limit' do
        before do
          allow(rate_limit_store).to receive(:increment).and_return(described_class::SIGN_UPS_PER_IP + 1)
        end

        it 'does not create a user' do
          expect { post(:create, params: { user: user_params }) }.not_to change { User.count }
          expect(response).to redirect_to new_user_registration_path
          expect(flash[:alert]).to eq described_class::TOO_MANY_SIGN_UPS_MESSAGE
        end
      end

      context 'when the IP is over its limit' do
        before do
          allow(rate_limit_store).to receive(:increment).and_call_original
          allow(rate_limit_store).to receive(:increment).
            with("sign_up:ip:203.0.113.7", any_args).and_return(described_class::SIGN_UPS_PER_IP + 1)
        end

        it 'does not count (or store) the email' do
          request.env['REMOTE_ADDR'] = '203.0.113.7'

          expect { post(:create, params: { user: user_params }) }.not_to change { User.count }
          expect(response).to redirect_to new_user_registration_path
          expect(rate_limit_store).not_to have_received(:increment).with("sign_up:email:pizza@example.com", any_args)
        end
      end
    end
  end

  describe "PUT update", as: :current_user do
    let(:current_user) { create :user }

    describe 'updating user details' do
      let!(:user_params) do
        {
          name: 'Quintus Batiatus II',
          enable_email_notifications: '0'
        }
      end

      it 'updates the user without requiring the current password' do
        put(:update, params: { id: current_user.id, user: user_params })

        current_user.reload
        expect(current_user.name).to eq user_params[:name]
        expect(current_user.enable_email_notifications).to eq false
      end
    end

    describe 'linking the account to an author' do
      let(:author) { create :author }

      it 'ignores `author_id` (only superadmins set it, on the users page)' do
        put(:update, params: { id: current_user.id, user: { name: 'New name', author_id: author.id } })

        current_user.reload
        expect(current_user.name).to eq 'New name'
        expect(current_user.author_id).to eq nil
      end
    end

    describe 'changing email' do
      let!(:original_email) { current_user.email }

      context 'without the current password' do
        it 'does not change the email' do
          put(:update, params: { id: current_user.id, user: { email: 'pizza2@example.com', name: 'New name' } })

          current_user.reload
          expect(current_user.email).to eq original_email
          expect(current_user.name).not_to eq 'New name'
        end
      end

      context 'with an incorrect current password' do
        it 'does not change the email' do
          user_params = { email: 'pizza2@example.com', current_password: 'wrong-password' }
          put(:update, params: { id: current_user.id, user: user_params })

          expect(current_user.reload.email).to eq original_email
        end
      end

      context 'with the current password' do
        it 'changes the email' do
          put(:update, params: { id: current_user.id, user: { email: 'pizza2@example.com', current_password: 'secret-password-1' } })

          expect(current_user.reload.email).to eq 'pizza2@example.com'
        end
      end

      context 'when the submitted email is unchanged (different case)' do
        it 'does not require the current password' do
          put(:update, params: { id: current_user.id, user: { email: original_email.upcase, name: 'New name' } })

          current_user.reload
          expect(current_user.email).to eq original_email
          expect(current_user.name).to eq 'New name'
        end
      end
    end

    describe 'changing password' do
      context 'without the current password' do
        it 'does not change the password' do
          user_params = { password: 'newsecret123', password_confirmation: 'newsecret123' }
          put(:update, params: { id: current_user.id, user: user_params })

          expect(current_user.reload.valid_password?('secret-password-1')).to eq true
        end
      end

      context 'with the current password' do
        it 'changes the password' do
          user_params = { password: 'newsecret123', password_confirmation: 'newsecret123', current_password: 'secret-password-1' }
          put(:update, params: { id: current_user.id, user: user_params })

          expect(current_user.reload.valid_password?('newsecret123')).to eq true
        end
      end
    end

    describe 'updating user settings for editing_helpers' do
      let!(:user_params) do
        {
          settings: {
            editing_helpers: {
              create_combination: "1"
            }
          }
        }
      end

      it 'updates the settings with type-casted values' do
        expect { put(:update, params: { id: current_user.id, user: user_params }) }.
          to change { current_user.reload.settings(:editing_helpers).create_combination }.
          from(false).to(true)
      end
    end

    describe 'updating unknown settings keys' do
      let!(:user_params) do
        {
          settings: {
            editing_helpers: {
              create_combination: "1",
              id: "999",
              var: "other",
              target_id: "999"
            }
          }
        }
      end

      it 'ignores keys that are not in the allowlist' do
        put(:update, params: { id: current_user.id, user: user_params })

        setting_object = current_user.reload.settings(:editing_helpers)
        expect(setting_object.create_combination).to eq true
        expect(setting_object.var).to eq 'editing_helpers'
        expect(setting_object.target_id).to eq current_user.id
        expect(setting_object.id).not_to eq 999
      end
    end
  end
end
