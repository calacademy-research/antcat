require 'spec_helper'

describe ApplicationController do

  describe "Authentication and authorization" do

    describe "Authentication and authorization to edit the catalog" do
      it "should ask the milieu" do
        @current_user = FactoryGirl.create :user, can_edit: true
        allow(controller).to receive(:current_user).and_return @current_user
        expect($Milieu).to receive(:user_can_edit?).with @current_user
        expect(controller).to receive(:authenticate_user!).and_return true
        controller.authenticate_editor
      end
    end

  end

end
