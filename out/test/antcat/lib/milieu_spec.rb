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
        expect(@milieu.user_can_upload_pdfs?(nil)).to be_truthy
        expect(@milieu.user_can_upload_pdfs?(@user)).to be_truthy
      end

      specify "Being an editor" do
        expect(@milieu.user_is_editor?(nil)).to be_falsey
        expect(@user).to receive(:is_editor?).and_return true
        expect(@milieu.user_is_editor?(@user)).to be_truthy
        expect(@user).to receive(:is_editor?).and_return false
        expect(@milieu.user_is_editor?(@user)).to be_falsey
      end

      specify "Editing references" do
        expect(@milieu.user_can_edit?(nil)).to be_falsey
        expect(@user).to receive(:is_editor?).and_return true
        expect(@milieu.user_can_edit?(@user)).to be_truthy
        expect(@user).to receive(:is_editor?).and_return false
        expect(@milieu.user_can_edit?(@user)).to be_falsey
      end

      specify "Editing the catalog" do
        expect(@milieu.user_can_edit?(nil)).to be_falsey
        expect(@user).to receive(:is_editor?).and_return true
        expect(@milieu.user_can_edit?(@user)).to be_truthy
        expect(@user).to receive(:is_editor?).and_return false
        expect(@milieu.user_can_edit?(@user)).to be_falsey
      end

      specify "Reviewing changes" do
        expect(@milieu.user_can_review_changes?(nil)).to be_falsey
        expect(@user).to receive(:can_review_changes?).and_return true
        expect(@milieu.user_can_review_changes?(@user)).to be_truthy
        expect(@user).to receive(:can_review_changes?).and_return false
        expect(@milieu.user_can_review_changes?(@user)).to be_falsey
      end

      specify "Approving changes" do
        expect(@milieu.user_can_approve_changes?(nil)).to be_falsey
        expect(@user).to receive(:can_approve_changes?).and_return true
        expect(@milieu.user_can_approve_changes?(@user)).to be_truthy
        expect(@user).to receive(:can_approve_changes?).and_return false
        expect(@milieu.user_can_approve_changes?(@user)).to be_falsey
      end
    end

    describe "Production milieu" do
      before do
        @user = double
        @milieu = SandboxMilieu.new
      end

      specify "Uploading PDFs" do
        expect(@milieu.user_can_upload_pdfs?(nil)).to be_falsey
        expect(@milieu.user_can_upload_pdfs?(@user)).to be_falsey
      end

      specify "Being an editor" do
        expect(@milieu.user_is_editor?(nil)).to be_truthy
        expect(@milieu.user_is_editor?(@user)).to be_truthy
      end

      specify "Editing references" do
        expect(@milieu.user_can_edit?(nil)).to be_truthy
        expect(@milieu.user_can_edit?(@user)).to be_truthy
        expect(@milieu.user_can_edit?(@user)).to be_truthy
      end

      specify "Editing the catalog" do
        expect(@milieu.user_can_edit?(nil)).to be_truthy
        expect(@milieu.user_can_edit?(@user)).to be_truthy
        expect(@milieu.user_can_edit?(@user)).to be_truthy
      end

      specify "Reviewing changes" do
        expect(@milieu.user_can_review_changes?(nil)).to be_truthy
        expect(@milieu.user_can_approve_changes?(@user)).to be_truthy
        expect(@milieu.user_can_approve_changes?(@user)).to be_truthy
      end

      specify "Approving changes" do
        expect(@milieu.user_can_approve_changes?(nil)).to be_truthy
        expect(@milieu.user_can_approve_changes?(@user)).to be_truthy
        expect(@milieu.user_can_approve_changes?(@user)).to be_truthy
      end

    end
  end
end
