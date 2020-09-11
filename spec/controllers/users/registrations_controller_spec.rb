# frozen_string_literal: true

require 'rails_helper'

describe Users::RegistrationsController do
  # To fix:
  #   Could not find devise mapping for path "/users/users".
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
        to change { Activity.where(action: :create).count }.by(1)
      expect(Activity.last.parameters).to eq(user_id: User.last.id)
    end

    context "when the New contributors' help page exists" do
      let!(:wiki_page) { create :wiki_page, :new_contributors_help_page }

      it 'redirects to it' do
        post(:create, params: { user: user_params })
        expect(response).to redirect_to "/wiki_pages/#{wiki_page.id}"
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
          email: 'pizza2@example.com',
          name: 'Quintus Batiatus II'
        }
      end

      it 'updates the user' do
        put(:update, params: { id: current_user.id, user: user_params })

        current_user.reload

        expect(current_user.email).to eq user_params[:email]
        expect(current_user.name).to eq user_params[:name]
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
  end
end
