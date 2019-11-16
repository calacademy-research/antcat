require 'spec_helper'

describe ReferencesController do
  describe "forbidden actions" do
    context "when not signed in" do
      specify { expect(get(:new)).to redirect_to_signin_form }
      specify { expect(get(:edit, params: { id: 1 })).to redirect_to_signin_form }
      specify { expect(post(:create)).to redirect_to_signin_form }
      specify { expect(put(:update, params: { id: 1 })).to redirect_to_signin_form }
    end

    context "when signed in as a helper editor" do
      before { sign_in create(:user, :helper) }

      specify { expect(delete(:destroy, params: { id: 1 })).to have_http_status :forbidden }
    end
  end

  describe "GET index" do
    specify { expect(get(:index)).to render_template :index }

    it "assigns @references" do
      reference = create :article_reference
      get :index
      expect(assigns(:references)).to eq [reference]
    end
  end

  describe "DELETE destroy" do
    let!(:reference) { create :unknown_reference }

    before { sign_in create(:user, :editor) }

    it 'deletes the reference' do
      expect { delete(:destroy, params: { id: reference.id }) }.to change { Reference.count }.by(-1)
    end

    it 'creates an activity' do
      reference_keey = reference.keey

      expect { delete(:destroy, params: { id: reference.id, edit_summary: 'Duplicate' }) }.
        to change { Activity.where(action: :destroy, trackable: reference).count }.by(1)

      activity = Activity.last
      expect(activity.edit_summary).to eq "Duplicate"
      expect(activity.parameters).to eq(name: reference_keey)
    end
  end
end
