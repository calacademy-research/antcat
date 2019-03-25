require 'spec_helper'

describe ProtonymsController do
  describe "forbidden actions" do
    context "when not signed in" do
      specify { expect(delete(:destroy, params: { id: 1 })).to redirect_to_signin_form }
      specify { expect(get(:edit, params: { id: 1 })).to redirect_to_signin_form }
      specify { expect(post(:update, params: { id: 1 })).to redirect_to_signin_form }
    end

    context "when signed in as a user" do
      before { sign_in create(:user) }

      specify { expect(get(:edit, params: { id: 1 })).to have_http_status :forbidden }
      specify { expect(post(:update, params: { id: 1 })).to have_http_status :forbidden }
      specify { expect(delete(:destroy, params: { id: 1 })).to have_http_status :forbidden }
    end
  end

  describe "POST update" do
    let!(:protonym) { create :protonym }

    before { sign_in create(:user, :helper) }

    it 'updates the protonym' do
      protonym_params = {
        fossil: false,
        sic: false,
        locality: 'Africa',
          authorship_attributes: {
            pages: '99',
            forms: 'worker',
            notes_taxt: 'see Lasius',
            reference_id: create(:article_reference).id
          }
      }

      post(:update, params: { id: protonym.id, protonym: protonym_params })

      protonym.reload
      expect(protonym.fossil).to eq protonym_params[:fossil]
      expect(protonym.sic).to eq protonym_params[:sic]
      expect(protonym.locality).to eq protonym_params[:locality]

      authorship = protonym.authorship
      expect(authorship.pages).to eq protonym_params[:authorship_attributes][:pages]
      expect(authorship.forms).to eq protonym_params[:authorship_attributes][:forms]
      expect(authorship.notes_taxt).to eq protonym_params[:authorship_attributes][:notes_taxt]
      expect(authorship.reference_id).to eq protonym_params[:authorship_attributes][:reference_id]
    end
  end

  describe "DELETE destroy" do
    let!(:protonym) { create :protonym }

    before { sign_in create(:user, :helper) }

    it 'deletes the protonym' do
      expect { delete(:destroy, params: { id: protonym.id }) }.
        to change { Protonym.count }.by(-1)
    end

    it 'creates an activity', :feed do
      expect { delete(:destroy, params: { id: protonym.id }) }.
        to change { Activity.where(action: :destroy, trackable: protonym).count }.by(1)
      expect(Activity.last.parameters).to eq(name: "<i>#{protonym.name.name}</i>")
    end

    context 'when protonym has a taxon' do
      before do
        create :family, protonym: protonym
      end

      specify do
        expect { delete(:destroy, params: { id: protonym.id }) }.
          to raise_error(ActiveRecord::StatementInvalid)
      end
    end
  end
end
