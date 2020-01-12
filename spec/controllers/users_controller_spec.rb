require 'rails_helper'

describe UsersController do
  describe "forbidden actions" do
    context "when signed in as a user" do
      before { sign_in create(:user) }

      specify { expect(get(:new)).to have_http_status :forbidden }
      specify { expect(get(:edit, params: { id: 1 })).to have_http_status :forbidden }
      specify { expect(post(:create)).to have_http_status :forbidden }
      specify { expect(put(:update, params: { id: 1 })).to have_http_status :forbidden }
      specify { expect(delete(:destroy, params: { id: 1 })).to have_http_status :forbidden }
    end

    context "when signed in as an editor" do
      before { sign_in create(:user, :editor) }

      specify { expect(get(:new)).to have_http_status :forbidden }
      specify { expect(get(:edit, params: { id: 1 })).to have_http_status :forbidden }
      specify { expect(post(:create)).to have_http_status :forbidden }
      specify { expect(put(:update, params: { id: 1 })).to have_http_status :forbidden }
      specify { expect(delete(:destroy, params: { id: 1 })).to have_http_status :forbidden }
    end
  end

  describe "GET new" do
    before { sign_in create(:user, :superadmin) }

    specify { expect(get(:new)).to render_template :new }
  end

  describe "POST create" do
    let!(:user_params) do
      {
        name: 'Captain Flynn',
        email: 'captain@flynn.com',
        password: 'secret123',
        helper: true,
        editor: true,
        superadmin: true,
        locked: true
      }
    end

    before { sign_in create(:user, :superadmin) }

    it 'creates a user' do
      expect { post(:create, params: { user: user_params }) }.to change { User.count }.by(1)

      user = User.last
      expect(user.name).to eq user_params[:name]
      expect(user.email).to eq user_params[:email]
      expect(user.helper).to eq user_params[:helper]
      expect(user.editor).to eq user_params[:editor]
      expect(user.superadmin).to eq user_params[:superadmin]
      expect(user.locked).to eq user_params[:locked]
    end
  end

  describe "PUT update" do
    let!(:user) { create :user }
    let!(:user_params) do
      {
        name: 'Captain Flynn',
        email: 'captain@flynn.com',
        helper: true,
        editor: true,
        superadmin: true,
        locked: true
      }
    end

    before { sign_in create(:user, :superadmin) }

    it 'updates the user' do
      put(:update, params: { id: user.id, user: user_params })

      user.reload
      expect(user.name).to eq user_params[:name]
      expect(user.email).to eq user_params[:email]
      expect(user.helper).to eq user_params[:helper]
      expect(user.editor).to eq user_params[:editor]
      expect(user.superadmin).to eq user_params[:superadmin]
      expect(user.locked).to eq user_params[:locked]
    end

    context 'when a new password is included' do
      let!(:user_params) do
        {
          password: 'verysecret123'
        }
      end

      it "updates the password" do
        expect { put(:update, params: { id: user.id, user: user_params }) }.
          to change { user.reload.encrypted_password }
      end
    end

    context 'when no new password not included' do
      it "does not update the password" do
        expect { put(:update, params: { id: user.id, user: user_params }) }.
          to_not change { user.reload.encrypted_password }
      end
    end
  end

  describe "DELETE destroy" do
    let!(:user) { create :user }

    before { sign_in create(:user, :superadmin) }

    it 'soft-deletes the user' do
      expect { delete(:destroy, params: { id: user.id }) }.to change { user.reload.deleted }.to(true)
    end

    it 'locks the user' do
      expect { delete(:destroy, params: { id: user.id }) }.to change { user.reload.locked }.to(true)
    end
  end
end
