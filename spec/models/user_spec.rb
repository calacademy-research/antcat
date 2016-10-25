require 'spec_helper'

describe User do
  it { should validate_presence_of(:name) }

  describe "scopes" do
    describe "scope.ordered_by_name" do
      before do
        create :user, name: "Anderson"
        create :user, name: "Zanderson"
        create :editor, name: "Banderson"
      end

      it "knows the alphabet" do
        expect(User.ordered_by_name.pluck :name).to eq %w( Anderson Banderson Zanderson )
      end
    end

    describe "editors and non-editors" do
      let!(:user) { create :user }
      let!(:editor) { create :editor }

      describe "scope.editors" do
        it "returns editors" do
          expect(User.editors).to eq [editor]
        end
      end

      describe "scope.non_editors" do
        it "returns non-editors" do
          expect(User.editors).to eq [editor]
        end
      end
    end

    describe "scope.feedback_emails_recipients" do
      let!(:user) { create :user, receive_feedback_emails: true }

      it "returns per the database" do
        expect(User.feedback_emails_recipients).to eq [user]
      end
    end

    describe "scope.as_angle_bracketed_emails" do
      before do
        create :user, name: "Archibald",
          email: "archibald@antcat.org", receive_feedback_emails: true
        create :user, name: "Batiatus",
          email: "batiatus@antcat.org", receive_feedback_emails: true
        create :user, name: "Flint", email: "flint@antcat.org"
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
    it "knows if it can edit the catalog" do
      expect(User.new.can_edit).to be_falsey
      expect(User.new(can_edit: true).can_edit).to be_truthy
    end

    it "knows if it can review changes" do
      expect(User.new.can_review_changes?).to be_falsey
      expect(User.new(can_edit: true).can_review_changes?).to be_truthy
    end

    it "knows if it can approve changes" do
      expect(User.new.can_approve_changes?).to be_falsey
      expect(User.new(can_edit: true).can_approve_changes?).to be_truthy
    end
  end

  describe "#angle_bracketed_email" do
    let(:user) do
      create :user, name: "A User", email: "user@example.com"
    end

    it "builds a string suitable for emails" do
      expect(user.angle_bracketed_email).to eq '"A User" <user@example.com>'
    end
  end
end
