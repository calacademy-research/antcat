# frozen_string_literal: true

require 'rails_helper'

describe ProtonymsController do
  describe "forbidden actions" do
    context "when not signed in", as: :visitor do
      specify { expect(get(:new)).to redirect_to_signin_form }
      specify { expect(post(:create, params: { id: 1 })).to redirect_to_signin_form }
      specify { expect(get(:edit, params: { id: 1 })).to redirect_to_signin_form }
      specify { expect(put(:update, params: { id: 1 })).to redirect_to_signin_form }
      specify { expect(delete(:destroy, params: { id: 1 })).to redirect_to_signin_form }
    end

    context "when signed in as a user", as: :user do
      specify { expect(get(:new)).to have_http_status :forbidden }
      specify { expect(post(:create, params: { id: 1 })).to have_http_status :forbidden }
      specify { expect(get(:edit, params: { id: 1 })).to have_http_status :forbidden }
      specify { expect(put(:update, params: { id: 1 })).to have_http_status :forbidden }
      specify { expect(delete(:destroy, params: { id: 1 })).to have_http_status :forbidden }
    end
  end

  describe "GET new", as: :helper do
    specify { expect(get(:new)).to render_template :new }
  end

  describe "POST create", as: :helper do
    let!(:protonym_params) do
      {
        fossil: false,
        sic: false,
        biogeographic_region: Protonym::NEARCTIC_REGION,
        locality: 'Africa',
        primary_type_information_taxt: "primary type information",
        secondary_type_information_taxt: "secondary type information",
        type_notes_taxt: "type notes",
        authorship_attributes: {
          pages: '99',
          forms: 'worker',
          notes_taxt: 'see Lasius',
          reference_id: create(:article_reference).id
        }
      }
    end
    let!(:params) do
      {
        protonym_name_string: "Atta",
        protonym: protonym_params
      }
    end

    it 'creates a protonym' do
      expect { post(:create, params: params) }.to change { Protonym.count }.by(1)

      protonym = Protonym.last
      expect(protonym.fossil).to eq protonym_params[:fossil]
      expect(protonym.sic).to eq protonym_params[:sic]
      expect(protonym.locality).to eq protonym_params[:locality]
      expect(protonym.biogeographic_region).to eq protonym_params[:biogeographic_region]
      expect(protonym.primary_type_information_taxt).to eq protonym_params[:primary_type_information_taxt]
      expect(protonym.secondary_type_information_taxt).to eq protonym_params[:secondary_type_information_taxt]
      expect(protonym.type_notes_taxt).to eq protonym_params[:type_notes_taxt]

      authorship = protonym.authorship
      expect(authorship.pages).to eq protonym_params[:authorship_attributes][:pages]
      expect(authorship.forms).to eq protonym_params[:authorship_attributes][:forms]
      expect(authorship.notes_taxt).to eq protonym_params[:authorship_attributes][:notes_taxt]
      expect(authorship.reference_id).to eq protonym_params[:authorship_attributes][:reference_id]
    end

    it 'creates an activity' do
      expect { post(:create, params: params.merge(edit_summary: 'Split protonym')) }.
        to change { Activity.where(action: :create).count }.by(1)

      activity = Activity.last
      protonym = Protonym.last
      expect(activity.trackable).to eq protonym
      expect(activity.edit_summary).to eq "Split protonym"
      expect(activity.parameters).to eq(name: "<i>#{protonym.name.name}</i>")
    end
  end

  describe "PUT update", as: :helper do
    let!(:protonym) { create :protonym }
    let(:protonym_params) do
      {
        fossil: false,
        sic: false,
        biogeographic_region: Protonym::NEARCTIC_REGION,
        locality: 'Africa',
        primary_type_information_taxt: "primary type information",
        secondary_type_information_taxt: "secondary type information",
        type_notes_taxt: "type notes",
        authorship_attributes: {
          pages: '99',
          forms: 'worker',
          notes_taxt: 'see Lasius',
          reference_id: create(:article_reference).id
        }
      }
    end

    it 'updates the protonym' do
      put(:update, params: { id: protonym.id, protonym: protonym_params })

      protonym.reload
      expect(protonym.fossil).to eq protonym_params[:fossil]
      expect(protonym.sic).to eq protonym_params[:sic]
      expect(protonym.biogeographic_region).to eq protonym_params[:biogeographic_region]
      expect(protonym.locality).to eq protonym_params[:locality]
      expect(protonym.primary_type_information_taxt).to eq protonym_params[:primary_type_information_taxt]
      expect(protonym.secondary_type_information_taxt).to eq protonym_params[:secondary_type_information_taxt]
      expect(protonym.type_notes_taxt).to eq protonym_params[:type_notes_taxt]

      authorship = protonym.authorship
      expect(authorship.pages).to eq protonym_params[:authorship_attributes][:pages]
      expect(authorship.forms).to eq protonym_params[:authorship_attributes][:forms]
      expect(authorship.notes_taxt).to eq protonym_params[:authorship_attributes][:notes_taxt]
      expect(authorship.reference_id).to eq protonym_params[:authorship_attributes][:reference_id]
    end

    it 'creates an activity' do
      expect { put(:update, params: { id: protonym.id, protonym: protonym_params, edit_summary: 'edited' }) }.
        to change { Activity.where(action: :update, trackable: protonym).count }.by(1)

      activity = Activity.last
      expect(activity.edit_summary).to eq "edited"
      expect(activity.parameters).to eq(name: "<i>#{protonym.name.name}</i>")
    end

    it 'updates the authorship in place without creating a new record' do
      new_pages = '99'
      protonym_params = {
        authorship_attributes: {
          pages: new_pages
        }
      }

      expect(protonym.authorship.pages).to_not eq new_pages
      expect { put(:update, params: { id: protonym.id, protonym: protonym_params }) }.
        to_not change { protonym.reload.authorship.id }
      expect(protonym.authorship.pages).to_not eq new_pages
    end
  end

  describe "DELETE destroy", as: :helper do
    let!(:protonym) { create :protonym }

    it 'deletes the protonym' do
      expect { delete(:destroy, params: { id: protonym.id }) }.to change { Protonym.count }.by(-1)
    end

    it 'creates an activity' do
      expect { delete(:destroy, params: { id: protonym.id }) }.
        to change { Activity.where(action: :destroy, trackable: protonym).count }.by(1)

      activity = Activity.last
      expect(activity.trackable_id).to eq protonym.id
      expect(activity.parameters).to eq(name: "<i>#{protonym.name.name}</i>")
    end

    context 'when protonym has a taxon' do
      before do
        create :family, protonym: protonym
      end

      specify do
        expect { delete(:destroy, params: { id: protonym.id }) }.to_not change { Protonym.count }
      end
    end
  end
end
