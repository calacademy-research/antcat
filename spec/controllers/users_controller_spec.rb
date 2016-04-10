require "spec_helper"

describe UsersController do
  # Testing cross-cutting concern here
  describe "ApplicationController#set_user_for_feed" do
    let(:user) { FactoryGirl.create :user }

    context "signed in" do
      before { sign_in user }

      it "sets the current user" do
        get :index
        expect(User.current_user).to eq user
      end
    end

    context "not signed in" do
      it "return nil without blowing up" do
        get :index
        expect(User.current_user).to eq nil
      end
    end
  end
end
