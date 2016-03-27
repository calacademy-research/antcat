require 'spec_helper'

describe User do

  it { should validate_presence_of(:name) }

  describe "scopes" do
    describe ".feedback_emails_recipients" do
      let!(:user) { FactoryGirl.create :user, receive_feedback_emails: true }

      it "returns per the database" do
        expect(User.feedback_emails_recipients).to eq [user]
      end
    end
  end

  describe "authorization" do
    it "knows whether it can edit the catalog" do
      expect(User.new.can_edit).to be_falsey
      expect(User.new(can_edit: true).can_edit).to be_truthy
    end

    it "knows whether it can review changes" do
      expect(User.new.can_review_changes?).to be_falsey
      expect(User.new(can_edit: true).can_review_changes?).to be_truthy
    end

    it "knows whether it can approve changes" do
      expect(User.new.can_approve_changes?).to be_falsey
      expect(User.new(can_edit: true).can_approve_changes?).to be_truthy
    end
  end

  describe "#angle_bracketed_email" do
    let(:user) do
      FactoryGirl.create :user, name: "An Editor", email: "editor@example.com"
    end

    it "builds a string suitable for emails" do
      expect(user.angle_bracketed_email).to eq '"An Editor" <editor@example.com>'
    end
  end

end
