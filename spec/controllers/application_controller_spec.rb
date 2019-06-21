require 'spec_helper'

describe ApplicationController do
  controller do
    def index
      @current_user = current_user
      render plain: "not ActionView::MissingTemplate: anonymous/index"
    end
  end

  describe "#set_user_for_feed" do
    context "when signed in" do
      let(:user) { create :user }

      before { sign_in user }

      it "sets the current user" do
        get :index
        expect(User.current).to eq user
      end
    end

    context "when not signed in" do
      it "returns nil without blowing up" do
        get :index
        expect(User.current).to eq nil
      end
    end
  end
end
