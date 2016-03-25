require 'spec_helper'

describe FeedbackController do

  describe '#create' do
    let(:json) do
      { format: "json", feedback: { comment: "Well done!" } }
    end

    context "valid feedback" do
      context "logged in" do
        it "sends emails" do
          sign_in FactoryGirl.create(:editor)
          expect { post :create, json }.to change { email_count }.by(1)
        end
      end

      context "not logged in" do
        it "sends emails" do
          expect { post :create, json }.to change { email_count }.by(1)
        end
      end
    end

    context "invalid feedback" do
      let!(:before_email_count) { email_count }

      context "logged in" do
        it "doesn't send emails" do
          sign_in FactoryGirl.create(:editor)
          expect { post :create, format: "json" }
           .to raise_error(ActionController::ParameterMissing)

          expect(email_count).to eq before_email_count
        end
      end

      context "not logged in" do
        it "doesn't send emails" do
          expect { post :create, format: "json" }
           .to raise_error(ActionController::ParameterMissing)

          expect(email_count).to eq before_email_count
        end
      end
    end
  end

end

def email_count
  ActionMailer::Base.deliveries.count
end
