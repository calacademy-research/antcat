require 'spec_helper'

describe User do
  it { should validate_presence_of :name }

  it { should be_versioned }

  describe "scopes" do
    describe ".editors and .non_editors" do
      let!(:user) { create :user }
      let!(:editor) { create :editor }

      describe ".editors" do
        it "returns editors" do
          expect(described_class.editors).to eq [editor]
        end
      end

      describe ".non_editors" do
        it "returns non-editors" do
          expect(described_class.editors).to eq [editor]
        end
      end
    end

    describe ".as_angle_bracketed_emails" do
      before do
        create :user, name: "Archibald",
          email: "archibald@antcat.org", receive_feedback_emails: true
        create :user, name: "Batiatus",
          email: "batiatus@antcat.org", receive_feedback_emails: true
        create :user, name: "Flint", email: "flint@antcat.org"
      end

      it "returns all user's #angle_bracketed_email" do
        expect(described_class.as_angle_bracketed_emails).to eq <<-STR.squish
          "Archibald" <archibald@antcat.org>,
          "Batiatus" <batiatus@antcat.org>,
          "Flint" <flint@antcat.org>
        STR
      end
    end
  end

  describe "authorization" do
    it "knows if it can edit the catalog" do
      expect(described_class.new.can_edit).to be_falsey
      expect(described_class.new(can_edit: true).can_edit).to be_truthy
    end

    it "knows if it can review changes" do
      expect(described_class.new.can_review_changes?).to be_falsey
      expect(described_class.new(can_edit: true).can_review_changes?).to be_truthy
    end

    it "knows if it can approve changes" do
      expect(described_class.new.can_approve_changes?).to be_falsey
      expect(described_class.new(can_edit: true).can_approve_changes?).to be_truthy
    end
  end

  describe "#angle_bracketed_email" do
    let(:user) { build_stubbed :user, name: "A User", email: "user@example.com" }

    it "builds a string suitable for emails" do
      expect(user.angle_bracketed_email).to eq '"A User" <user@example.com>'
    end
  end

  describe "#notify_because" do
    let(:user) { create :user }
    let(:notifier) { create :user }
    let(:issue) { create :issue }

    context "user and notifier are the same" do
      it "doesn't create a notification" do
        expect do
          user.notify_because :mentioned_in_thing, attached: issue, notifier: user
        end.to_not change { Notification.count }
      end
    end

    context "user has already been notified for that attached/notifier combination" do
      it "doesn't create a notification" do
        user.notify_because :mentioned_in_thing, attached: issue, notifier: notifier

        expect do
          user.notify_because :mentioned_in_thing, attached: issue, notifier: notifier
        end.to_not change { Notification.count }
      end
    end

    it "*test the above shaky examples that may fail for other reasons*" do
      expect do
        user.notify_because :mentioned_in_thing, attached: issue, notifier: notifier
      end.to change { Notification.count }.by 1
    end
  end

  describe "#already_notified_for_attached_by_user?" do
    let(:user) { create :user }
    let(:notifier) { create :user }
    let(:issue) { create :issue }

    it "can tell" do
      notified = user.send :already_notified_for_attached_by_user?, issue, notifier
      expect(notified).to be_falsey

      user.notify_because :mentioned_in_thing, attached: issue, notifier: notifier

      notified_now_then = user.send :already_notified_for_attached_by_user?, issue, notifier
      expect(notified_now_then).to be true
    end
  end
end
