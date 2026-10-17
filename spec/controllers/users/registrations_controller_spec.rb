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
        name: 'Quintus Batiatus',
        password: 'secret123',
        password_confirmation: 'secret123'
      }
    end

    it 'creates a user' do
      expect { post(:create, params: { user: user_params }) }.to change { User.count }.by(1)

      user = User.last
      expect(user.email).to eq user_params[:email]
      expect(user.name).to eq user_params[:name]
      expect(user.helper).to eq false
      expect(user.editor).to eq false
      expect(user.superadmin).to eq false
    end

    it 'creates an activity' do
      expect { post(:create, params: { user: user_params }) }.
        to change { Activity.where(event: Activity::CREATE).count }.by(1)
      expect(Activity.last.parameters).to eq(user_id: User.last.id)
    end

    context "when the New contributors' help page exists" do
      let!(:wiki_page) { create :wiki_page, :new_contributors_help_page }

      it 'redirects to it' do
        post(:create, params: { user: user_params })
        expect(response).to redirect_to "/wiki/#{wiki_page.id}"
      end
    end

    context 'when submitting unpermitted attributes' do
      let!(:with_unpermitted_params) do
        user_params.merge(helper: true, editor: true, superadmin: true)
      end

      it 'ignores them' do
        expect { post(:create, params: { user: with_unpermitted_params }) }.to change { User.count }.by(1)

        user = User.last
        expect(user.helper).to eq false
        expect(user.editor).to eq false
        expect(user.superadmin).to eq false
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
          put(:update, params: { id: current_user.id, user: { email: 'pizza2@example.com', current_password: 'secret' } })

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

          expect(current_user.reload.valid_password?('secret')).to eq true
        end
      end

      context 'with the current password' do
        it 'changes the password' do
          user_params = { password: 'newsecret123', password_confirmation: 'newsecret123', current_password: 'secret' }
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
