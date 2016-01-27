require 'spec_helper'

describe ApplicationController do
  let!(:editor) { FactoryGirl.create :user, can_edit: true }

  controller do
    def index
      @current_user = current_user
      render text: "not ActionView::MissingTemplate: anonymous/index"
    end
  end

  describe "Authorization" do
    context "not signed in" do
      it "return a user's roles" do
        expect(controller.user_can_edit?).to be nil
        expect(controller.user_is_superadmin?).to be nil
      end
    end

    context "signed in as editor" do
      before do
        sign_in editor
        get :index
      end

      it "assigns the current_user" do
        expect(assigns(:current_user)).to eq editor
      end

      it "knows stuff" do
        expect(controller.user_can_edit?).to be true
        expect(controller.user_is_superadmin?).to be_falsey
      end
    end

    it "delegates to User" do
      current_user = editor
      allow(controller).to receive(:current_user).and_return current_user
      expect(current_user).to receive(:can_edit?)
      expect(controller).to receive(:authenticate_user!).and_return true
      controller.authenticate_editor
    end
  end

end
