require 'spec_helper'

describe ProtonymsController do
  describe "forbidden actions" do
    context "when not signed in" do
      specify { expect(delete(:destroy, params: { id: 1 })).to redirect_to_signin_form }
    end

    context "when signed in as a user" do
      before { sign_in create(:user) }

      specify { expect(delete(:destroy, params: { id: 1 })).to have_http_status :forbidden }
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
