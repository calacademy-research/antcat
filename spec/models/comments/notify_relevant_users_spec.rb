require "spec_helper"

describe Comments::NotifyRelevantUsers do
  let(:me) { Comments::NotifyRelevantUsers }

  describe "#notify_replied_to_user" do
    context "is not a reply" do
      let(:instance) { me.new build_stubbed(:comment) }

      it "doesn't try to notify" do
        expect { instance.send :notify_replied_to_user }
          .not_to change { Notification.count }
      end
    end

    context "is a reply" do
      let(:instance) do
        reply = build_stubbed :reply, user: build_stubbed(:user)
        me.new reply
      end

      it "notifies" do
        expect { instance.send :notify_replied_to_user }
          .to change { Notification.count }.by 1
      end
    end
  end

  describe "#notify_mentioned_users" do
    let(:instance) do
      body = "@user#{create(:user).id} @user#{create(:user).id}"
      comment = build_stubbed :comment, body: body, user: create(:user)
      me.new comment
    end

    context "user has already been notified" do
      before { allow(instance).to receive(:do_not_notify?).and_return true }

      it "doesn't notify" do
        expect { instance.send :notify_mentioned_users }
          .not_to change { Notification.count }
      end
    end

    context "user has not been notified" do
      it "notifies" do
        expect { instance.send :notify_mentioned_users }
          .to change { Notification.count }.by 2
      end
    end
  end

  describe "#notify_users_in_the_same_discussion" do
    let(:commentable) { create :issue }
    let(:instance) do
      comment = build_stubbed :comment, commentable: commentable
      me.new comment
    end
    before { create :comment, commentable: commentable }

    context "user has already been notified" do
      before { allow(instance).to receive(:do_not_notify?).and_return true }

      it "doesn't notify" do
        expect { instance.send :notify_users_in_the_same_discussion }
          .not_to change { Notification.count }
      end
    end

    context "user has not been notified" do
      it "notifies" do
        expect { instance.send :notify_users_in_the_same_discussion }
          .to change { Notification.count }.by 1
      end
    end
  end

  describe "#notify_commentable_creator" do
    let(:instance) do
      comment = build_stubbed :comment, commentable: build_stubbed(:issue)
      me.new comment
    end

    context "user has already been notified" do
      before { allow(instance).to receive(:do_not_notify?).and_return true }

      it "doesn't notify" do
        expect { instance.send :notify_commentable_creator }
          .not_to change { Notification.count }
      end
    end

    context "user has not been notified" do
      it "notifies" do
        expect { instance.send :notify_commentable_creator }
          .to change { Notification.count }.by 1
      end
    end
  end

  describe "#users_mentioned_in_comment" do
    let(:comment) { build_stubbed :comment }
    let(:instance) { me.new comment }

    it "delegates" do
      expect(AntcatMarkdownUtils).to receive(:users_mentioned_in).with comment.body
      instance.send :users_mentioned_in_comment
    end
  end

  describe "#do_not_notify? and #no_more_notifications_for" do
    let(:comment) { build_stubbed :comment }
    let(:instance) { me.new comment }

    context "user is same as commenter" do
      it "is true (do not notify)" do
        results = instance.send :do_not_notify?, comment.user
        expect(results).to be true
      end
    end

    context "#no_more_notifications_for has not been called for user" do
      it "is false (do notify)" do
        results = instance.send :do_not_notify?, build_stubbed(:user)
        expect(results).to be false
      end
    end

    context "#no_more_notifications_for has been called for user" do
      it "is true (do not notify)" do
        user = build_stubbed :user
        instance.send :no_more_notifications_for, user

        results = instance.send :do_not_notify?, user
        expect(results).to be true
      end
    end
  end
end
