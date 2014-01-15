# coding: UTF-8
require 'spec_helper'

describe ApplicationController do

  describe "Authentication and authorization" do
    before do
      @current_user = double
      controller.stub(:current_user).and_return @current_user
    end
    describe "Authentication and authorization to edit the catalog" do
      it "should ask the milieu" do
        $Milieu.should_receive(:user_can_edit?).with @current_user
        controller.should_receive(:authenticate_user!).and_return true
        controller.authenticate_editor
      end
    end
  end

end
