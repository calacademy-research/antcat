# frozen_string_literal: true

require 'rails_helper'

describe Taxa::ForceUpdatesController do
  describe "forbidden actions" do
    context "when signed in as an editor", as: :editor do
      specify { expect(get(:show, params: { taxa_id: 1 })).to have_http_status :forbidden }
      specify { expect(put(:update, params: { taxa_id: 1 })).to have_http_status :forbidden }
    end
  end

  describe "GET show", as: :superadmin do
    let(:taxon) { create :family }

    specify { expect(get(:show, params: { taxa_id: taxon.id })).to render_template :show }
  end

  describe "PUT update", as: :superadmin do
    let(:taxon) { create :tribe }

    context 'when edit summary is missing' do
      let(:params) do
        {
          taxa_id: taxon.id,
          taxon: { status: taxon.status }
        }
      end

      it 'renders a warning' do
        put :update, params: params

        expect(response.request.flash[:error]).to eq "An edit summary is required for this change."
      end
    end

    context 'with valid params' do
      let(:new_subfamily) { create :subfamily }
      let(:params) do
        {
          taxa_id: taxon.id,
          edit_summary: 'Fix broken',
          taxon: {
            subfamily_id: new_subfamily.id
          }
        }
      end

      it 'updates the taxon with minimal validations' do
        expect(taxon.subfamily).to_not eq new_subfamily

        put :update, params: params

        taxon.reload
        expect(taxon.subfamily).to eq new_subfamily

        expect(response).to redirect_to catalog_path(taxon)
        expect(response.request.flash[:notice]).to eq "Successfully force-updated database record."
      end

      it 'creates an activity' do
        expect { put(:update, params: params) }.
          to change { Activity.where(action: Activity::FORCE_UPDATE_DATABASE_RECORD).count }.by(1)

        activity = Activity.last
        expect(activity.trackable).to eq taxon
        expect(activity.edit_summary).to eq 'Fix broken'
      end
    end
  end
end
