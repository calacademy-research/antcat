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

    describe ".as_angle_bracketed_emails" do
      before do
        FactoryGirl.create :editor, name: "Archibald",
          email: "archibald@antcat.org", receive_feedback_emails: true
        FactoryGirl.create :editor, name: "Batiatus",
          email: "batiatus@antcat.org", receive_feedback_emails: true

        FactoryGirl.create :editor, name: "Flint",
          email: "flint@antcat.org"
      end

      it "returns all user's #angle_bracketed_email" do
        expect(User.as_angle_bracketed_emails).to eq <<-STR.squish
          "Archibald" <archibald@antcat.org>,
          "Batiatus" <batiatus@antcat.org>,
          "Flint" <flint@antcat.org>
        STR
      end

      it "handles scopes" do
        actual = User.feedback_emails_recipients.as_angle_bracketed_emails
        expect(actual).to eq <<-STR.squish
          "Archibald" <archibald@antcat.org>,
          "Batiatus" <batiatus@antcat.org>
        STR
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
