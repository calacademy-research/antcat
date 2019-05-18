require 'spec_helper'

describe My::RegistrationsController do
  # To fix:
  #   Could not find devise mapping for path "/my/users".
  #   ...
  #   2) You are testing a Devise controller bypassing the router.
  #      If so, you can explicitly tell Devise which mapping to use ...
  before do
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end

  describe "POST create" do
    let!(:user_params) do
      {
        email: 'pizza@example.com"',
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

    it 'creates an activity', :feed do
      expect { post(:create, params: { user: user_params }) }.
        to change { Activity.where(action: :create).count }.by(1)
      expect(Activity.last.parameters).to eq(user_id: User.last.id)
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
end
