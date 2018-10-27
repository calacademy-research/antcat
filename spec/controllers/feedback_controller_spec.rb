require 'spec_helper'

describe FeedbackController do
  describe "forbidden actions" do
    context "when signed in as a user" do
      before { sign_in create(:user) }

      specify { expect(get(:show, params: { id: 1 })).to have_http_status :forbidden }
      specify { expect(get(:index)).to have_http_status :forbidden }
      specify { expect(delete(:destroy, params: { id: 1 })).to have_http_status :forbidden }
      specify { expect(delete(:reopen, params: { id: 1 })).to have_http_status :forbidden }
      specify { expect(delete(:close, params: { id: 1 })).to have_http_status :forbidden }
    end

    context "when signed in as a helper" do
      before { sign_in create(:user, :helper) }

      specify { expect(delete(:destroy, params: { id: 1 })).to have_http_status :forbidden }
    end
  end

  describe "#create" do
    around do |example|
      InvisibleCaptcha.setup { |config| config.timestamp_enabled = false }
      example.run
      InvisibleCaptcha.setup { |config| config.timestamp_enabled = true }
    end

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
      before do
        post :create, params: valid_params
      end

      it "does not create a feedback item" do
        expect { post :create, params: valid_params }.to_not change { Feedback.count }.from(1)
        expect(response).to have_http_status :unprocessable_entity
      end

      it "includes a friendly error message in the response" do
        post :create, params: valid_params
        expect(json_response["comment"].first).to include "has already been submitted. If it is unlikely"
      end
    end
  end
end
