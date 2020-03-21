require 'rails_helper'

describe FeedbackController do
  describe "forbidden actions" do
    context "when signed in as a user", as: :user do
      specify { expect(get(:show, params: { id: 1 })).to have_http_status :forbidden }
      specify { expect(get(:index)).to have_http_status :forbidden }
      specify { expect(delete(:destroy, params: { id: 1 })).to have_http_status :forbidden }
      specify { expect(delete(:reopen, params: { id: 1 })).to have_http_status :forbidden }
      specify { expect(delete(:close, params: { id: 1 })).to have_http_status :forbidden }
    end

    context "when signed in as an editor", as: :editor do
      specify { expect(delete(:destroy, params: { id: 1 })).to have_http_status :forbidden }
    end
  end

  describe "POST create" do
    let(:valid_params) do
      { feedback: { comment: "Cool site", name: "Batiatus" }, format: :json }
    end

    context "when feedback is valid" do
      it "creates a feedback item" do
        expect { post :create, params: valid_params }.to change { Feedback.count }.from(0).to(1)
        expect(response).to have_http_status :created
      end
    end

    context "when a feedback with the same comment already exists" do
      before { post :create, params: valid_params }

      it "does not create a feedback item" do
        expect { post :create, params: valid_params }.to_not change { Feedback.count }.from(1)
      end

      it "includes a friendly error message in the response" do
        post :create, params: valid_params
        expect(response.body).to include "has already been submitted. If it is unlikely"
        expect(response).to have_http_status :unprocessable_entity
      end
    end
  end

  describe "DELETE destroy" do
    let!(:feedback) { create :feedback }

    before { sign_in create(:user, :superadmin, :helper) }

    it 'deletes the feedback' do
      expect { delete(:destroy, params: { id: feedback.id }) }.to change { Feedback.count }.by(-1)
    end

    it 'creates an activity' do
      expect { delete(:destroy, params: { id: feedback.id }) }.
        to change { Activity.where(action: :destroy, trackable: feedback).count }.by(1)
    end
  end
end
