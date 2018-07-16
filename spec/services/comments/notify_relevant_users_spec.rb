require "spec_helper"

describe Comments::NotifyRelevantUsers do
  describe "#notify_replied_to_user" do
    context "when is not a reply" do
      let(:subject) { described_class.new build_stubbed(:comment) }

      it "doesn't try to notify" do
        expect { subject.send :notify_replied_to_user }.
          not_to change { Notification.count }
      end
    end

    context "when is a reply" do
      let(:subject) do
        reply = build_stubbed :comment, :reply, user: build_stubbed(:user)
        described_class.new reply
      end

      it "notifies" do
        expect { subject.send :notify_replied_to_user }.
          to change { Notification.count }.by 1
      end
    end
  end

  describe "#notify_mentioned_users" do
    let(:subject) do
      body = "@user#{create(:user).id} @user#{create(:user).id}"
      comment = build_stubbed :comment, body: body, user: create(:user)
      described_class.new comment
    end

    context "when user has already been notified" do
      before { allow(subject).to receive(:do_not_notify?).and_return true }

      it "doesn't notify" do
        expect { subject.send :notify_mentioned_users }.
          not_to change { Notification.count }
      end
    end

    context "when user has not been notified" do
      it "notifies" do
        expect { subject.send :notify_mentioned_users }.
          to change { Notification.count }.by 2
      end
    end
  end

  describe "#notify_users_in_the_same_discussion" do
    let(:commentable) { create :issue }
    let(:subject) do
      comment = build_stubbed :comment, commentable: commentable
      described_class.new comment
    end

    before { create :comment, commentable: commentable }

    context "when user has already been notified" do
      before { allow(subject).to receive(:do_not_notify?).and_return true }

      it "doesn't notify" do
        expect { subject.send :notify_users_in_the_same_discussion }.
          not_to change { Notification.count }
      end
    end

    context "when user has not been notified" do
      it "notifies" do
        expect { subject.send :notify_users_in_the_same_discussion }.
          to change { Notification.count }.by 1
      end
    end
  end

  describe "#notify_commentable_creator" do
    let(:subject) do
      comment = build_stubbed :comment, commentable: build_stubbed(:issue)
      described_class.new comment
    end

    context "when user has already been notified" do
      before { allow(subject).to receive(:do_not_notify?).and_return true }

      it "doesn't notify" do
        expect { subject.send :notify_commentable_creator }.
          not_to change { Notification.count }
      end
    end

    context "when user has not been notified" do
      it "notifies" do
        expect { subject.send :notify_commentable_creator }.
          to change { Notification.count }.by 1
      end
    end
  end

  describe "#users_mentioned_in_comment" do
    let(:comment) { build_stubbed :comment }
    let(:subject) { described_class.new comment }

    it "delegates" do
      expect(Markdowns::MentionedUsers).to receive(:new).
        with(comment.body).and_call_original
      subject.send :users_mentioned_in_comment
    end
  end

  describe "#do_not_notify? and #no_more_notifications_for" do
    let(:comment) { build_stubbed :comment }
    let(:subject) { described_class.new comment }

    context "when user is same as commenter" do
      it "is true (do not notify)" do
        expect(subject.send :do_not_notify?, comment.user).to be true
      end
    end

    context "when #no_more_notifications_for has not been called for user" do
      it "is false (do notify)" do
        expect(subject.send :do_not_notify?, build_stubbed(:user)).to be false
      end
    end

    context "when #no_more_notifications_for has been called for user" do
      let(:user) { build_stubbed :user }

      it "is true (do not notify)" do
        expect { subject.send :no_more_notifications_for, user }.
          to change { subject.send :do_not_notify?, user }.from(false).to(true)
      end
    end
  end
end
