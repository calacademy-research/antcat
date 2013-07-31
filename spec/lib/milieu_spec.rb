# coding: UTF-8
require 'spec_helper'
describe Milieu do

  describe "Authorization" do
    describe "Production milieu" do
      before do
        @user = double
        @milieu = RestrictedMilieu.new
      end

      specify "Uploading PDFs" do
        @milieu.user_can_upload_pdfs?(nil).should be_true
        @milieu.user_can_upload_pdfs?(@user).should be_true
      end

      specify "Being an editor" do
        @milieu.user_is_editor?(nil).should be_false
        @user.should_receive(:is_editor?).and_return true
        @milieu.user_is_editor?(@user).should be_true
        @user.should_receive(:is_editor?).and_return false
        @milieu.user_is_editor?(@user).should be_false
      end

      specify "Editing references" do
        @milieu.user_can_edit_references?(nil).should be_false
        @user.should_receive(:is_editor?).and_return true
        @milieu.user_can_edit_references?(@user).should be_true
        @user.should_receive(:is_editor?).and_return false
        @milieu.user_can_edit_references?(@user).should be_false
      end

      specify "Editing the catalog" do
        @milieu.user_can_edit_catalog?(nil).should be_false
        @user.should_receive(:can_edit_catalog?).and_return true
        @milieu.user_can_edit_catalog?(@user).should be_true
        @user.should_receive(:can_edit_catalog?).and_return false
        @milieu.user_can_edit_catalog?(@user).should be_false
      end

      specify "Reviewing changes" do
        @milieu.user_can_review_changes?(nil).should be_false
        @user.should_receive(:can_approve_changes?).and_return true
        @milieu.user_can_approve_changes?(@user).should be_true
        @user.should_receive(:can_approve_changes?).and_return false
        @milieu.user_can_approve_changes?(@user).should be_false
      end

      specify "Approving changes" do
        @milieu.user_can_approve_changes?(nil).should be_false
        @user.should_receive(:can_approve_changes?).and_return true
        @milieu.user_can_approve_changes?(@user).should be_true
        @user.should_receive(:can_approve_changes?).and_return false
        @milieu.user_can_approve_changes?(@user).should be_false
      end
    end

    describe "Production milieu" do
      before do
        @user = double
        @milieu = SandboxMilieu.new
      end

      specify "Uploading PDFs" do
        @milieu.user_can_upload_pdfs?(nil).should be_false
        @milieu.user_can_upload_pdfs?(@user).should be_false
      end

      specify "Being an editor" do
        @milieu.user_is_editor?(nil).should be_true
        @milieu.user_is_editor?(@user).should be_true
      end

      specify "Editing references" do
        @milieu.user_can_edit_references?(nil).should be_true
        @milieu.user_can_edit_references?(@user).should be_true
        @milieu.user_can_edit_references?(@user).should be_true
      end

      specify "Editing the catalog" do
        @milieu.user_can_edit_catalog?(nil).should be_true
        @milieu.user_can_edit_catalog?(@user).should be_true
        @milieu.user_can_edit_catalog?(@user).should be_true
      end

      specify "Reviewing changes" do
        @milieu.user_can_review_changes?(nil).should be_true
        @milieu.user_can_approve_changes?(@user).should be_true
        @milieu.user_can_approve_changes?(@user).should be_true
      end

      specify "Approving changes" do
        @milieu.user_can_approve_changes?(nil).should be_true
        @milieu.user_can_approve_changes?(@user).should be_true
        @milieu.user_can_approve_changes?(@user).should be_true
      end

    end
  end
end
