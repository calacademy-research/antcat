# frozen_string_literal: true

require 'rails_helper'

describe NamesController do
  describe "forbidden actions" do
    context "when signed in as a user", as: :user do
      specify { expect(get(:edit, params: { id: 1 })).to have_http_status :forbidden }
      specify { expect(put(:update, params: { id: 1 })).to have_http_status :forbidden }
    end

    context "when signed in as a helper", as: :helper do
      specify { expect(get(:edit, params: { id: 1 })).to have_http_status :forbidden }
      specify { expect(put(:update, params: { id: 1 })).to have_http_status :forbidden }
    end
  end

  describe "PUT update", as: :editor do
    context 'with valid params' do
      let!(:name) { create :subspecies_name }
      let(:params) do
        {
          id: name.id,
          type: 'SubspeciesName',
          name: {
            name: 'Brandus noviusia  nameus',
            non_conforming: 'true'
          }
        }
      end

      it 'updates the name' do
        put :update, params: params

        name.reload
        expect(name.name).to eq 'Brandus noviusia nameus'
        expect(name.epithet).to eq 'nameus'
        expect(name.non_conforming).to eq true
      end

      it 'creates an activity' do
        expect { put :update, params: params }.to change { Activity.count }.by(1)

        activity = Activity.last
        expect(activity.trackable).to eq name
        expect(activity.action).to eq 'update'
        expect(activity.parameters).to eq name_html: name.reload.name_html
      end
    end
  end
end
