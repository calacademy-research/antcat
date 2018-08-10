require 'spec_helper'

describe ApplicationController do
  controller do
    def index
      @current_user = current_user
      render plain: "not ActionView::MissingTemplate: anonymous/index"
    end
  end

  describe "Authorization" do
    context "when not signed in" do
      before { get :index }

      it "defaults user right to nil" do
        expect(controller.user_can_edit?).to be nil
        expect(controller.user_is_superadmin?).to be nil
      end
    end

    context "when signed in as an editor" do
      let!(:editor) { create :editor }

      before do
        sign_in editor
        get :index
      end

      it "assigns the current_user" do
        expect(assigns(:current_user)).to eq editor
      end

      it "knows what editors are allow to do" do
        expect(controller.user_can_edit?).to be true
        expect(controller.user_is_superadmin?).to be false
      end
    end

    context "when signed in as a superadmin" do
      let!(:superadmin) { create :user, is_superadmin: true }

      before do
        sign_in superadmin
        get :index
      end

      it "assigns the current_user" do
        expect(assigns(:current_user)).to eq superadmin
      end

      it "knows what superadmins are allow to do" do
        expect(controller.user_can_edit?).to be false
        expect(controller.user_is_superadmin?).to be true
      end
    end

    it "delegates to User" do
      current_user = create :editor
      allow(controller).to receive(:current_user).and_return current_user

      expect(current_user).to receive :can_edit?
      expect(controller).to receive(:authenticate_user!).and_return true
      controller.send :authenticate_editor
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
