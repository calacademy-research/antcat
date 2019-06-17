require 'spec_helper'

describe NamesController do
  describe "forbidden actions" do
    context "when signed in as a user" do
      before { sign_in create(:user) }

      specify { expect(get(:edit, params: { id: 1 })).to have_http_status :forbidden }
      specify { expect(post(:update, params: { id: 1 })).to have_http_status :forbidden }
      specify { expect(delete(:destroy, params: { id: 1 })).to have_http_status :forbidden }
    end

    context "when signed in as a helper" do
      before { sign_in create(:user, :helper) }

      specify { expect(get(:edit, params: { id: 1 })).to have_http_status :forbidden }
      specify { expect(post(:update, params: { id: 1 })).to have_http_status :forbidden }
      specify { expect(delete(:destroy, params: { id: 1 })).to have_http_status :forbidden }
    end
  end

  describe "POST update" do
    before { sign_in create(:user, :editor) }

    context 'with valid params' do
      let!(:name) { create :subspecies_name }
      let(:params) do
        {
          id: name.id,
          type: 'SubspeciesName',
          name: {
            name: 'Brandus noviusia  nameus'
          }
        }
      end

      it 'updates the name' do
        post :update, params: params

        name.reload
        expect(name.name).to eq 'Brandus noviusia nameus'
        expect(name.epithet).to eq 'nameus'
        expect(name.epithets).to eq 'noviusia nameus'
      end

      it 'creates an activity' do
        expect { post :update, params: params }.to change { Activity.count }.by(1)

        activity = Activity.last
        expect(activity.trackable).to eq name
        expect(activity.action).to eq 'update'
        expect(activity.parameters).to eq name_html: name.reload.name_html
      end
    end
  end

  describe "DELETE destroy" do
    before { sign_in create(:user, :editor) }

    context 'when name can be destroyed' do
      let!(:name) { create :subspecies_name }

      it 'destroys the name' do
        expect { delete :destroy, params: { id: name.id } }.to change { Name.count }.by(-1)
      end

      it 'creates an activity' do
        expect { delete :destroy, params: { id: name.id } }.to change { Activity.count }.by(1)

        activity = Activity.last
        expect(activity.trackable_id).to eq name.id
        expect(activity.action).to eq 'destroy'
        expect(activity.parameters).to eq name_html: name.name_html
      end
    end
  end
end
