require 'spec_helper'

describe NamesController do
  describe "forbidden actions" do
    context "when signed in as a user" do
      before { sign_in create(:user) }

      specify { expect(get(:edit, params: { id: 1 })).to have_http_status :forbidden }
      specify { expect(post(:update, params: { id: 1 })).to have_http_status :forbidden }
    end

    context "when signed in as a helper" do
      before { sign_in create(:user, :helper) }

      specify { expect(get(:edit, params: { id: 1 })).to have_http_status :forbidden }
      specify { expect(post(:update, params: { id: 1 })).to have_http_status :forbidden }
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
          subspecies_name: {
            name: 'Brandus noviusia nameus',
            epithet: 'nameus',
            epithets: 'noviusia nameus'
          }
        }
      end

      it 'updates the name' do
        post :update, params: params

        name.reload
        subspecies_name_params = params[:subspecies_name]
        expect(name.name).to eq subspecies_name_params[:name]
        expect(name.epithet).to eq subspecies_name_params[:epithet]
        expect(name.epithets).to eq subspecies_name_params[:epithets]
      end

      it 'creates an activity', :feed do
        expect { post :update, params: params }.to change { Activity.count }.by(1)
        expect(Activity.last.trackable).to eq name
      end
    end
  end
end
