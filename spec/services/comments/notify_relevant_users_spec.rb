require 'rails_helper'

describe Comments::NotifyRelevantUsers do
  let(:service) { described_class.new comment }
  let(:commentable) { create :issue }
  let(:notifier) { create :user }

  describe "#notify_mentioned_users" do
    let(:mentioned_user) { create(:user) }
    let(:comment) { create :comment, body: "@user#{mentioned_user.id}", commentable: commentable, user: notifier }

    before do
      make_sure_creator_of_commentable_is_already_notified commentable, comment
    end

    context "when user has already been notified" do
      before do
        mentioned_user.notify_because :mentioned_in_comment, attached: comment, notifier: comment.user
      end

      it "doesn't notify for this reason" do
        expect { service.call }.not_to change { Notification.count }
      end
    end

    context "when user has not been notified" do
      it "notifies" do
        expect { service.call }.to change { Notification.count }.by 1

        notification = Notification.last
        expect(notification.user).to eq mentioned_user
        expect(notification.reason).to eq 'mentioned_in_comment'
        expect(notification.notifier).to eq notifier
        expect(notification.attached).to eq comment
      end
    end
  end

  describe "#notify_users_in_the_same_discussion" do
    let(:same_discussion_user) { create(:user) }
    let(:comment) { create :comment, commentable: commentable, user: notifier }

    before do
      create :comment, commentable: commentable, user: same_discussion_user
      make_sure_creator_of_commentable_is_already_notified commentable, comment
    end

    context "when user has already been notified" do
      before do
        same_discussion_user.notify_because :active_in_discussion, attached: comment, notifier: comment.user
      end

      it "doesn't notify for this reason" do
        expect { service.call }.not_to change { Notification.count }
      end
    end

    context "when user has not been notified" do
      it "notifies" do
        expect { service.call }.to change { Notification.count }.by 1

        notification = Notification.last
        expect(notification.user).to eq same_discussion_user
        expect(notification.reason).to eq 'active_in_discussion'
        expect(notification.notifier).to eq notifier
        expect(notification.attached).to eq comment
      end
    end
  end

  describe "#notify_commentable_creator" do
    let(:comment) { create :comment, commentable: commentable, user: notifier }

    context "when user has already been notified" do
      before do
        commentable.user.notify_because :creator_of_commentable, attached: comment, notifier: comment.user
      end

      it "doesn't notify for this reason" do
        expect { service.call }.not_to change { Notification.count }
      end
    end

    context "when user has not been notified" do
      it "notifies" do
        expect { service.call }.to change { Notification.count }.by 1

        notification = Notification.last
        expect(notification.user).to eq commentable.user
        expect(notification.reason).to eq 'creator_of_commentable'
        expect(notification.notifier).to eq notifier
        expect(notification.attached).to eq comment
      end
    end
  end

  def make_sure_creator_of_commentable_is_already_notified commentable, comment
    commentable.user.notify_because :creator_of_commentable, attached: comment, notifier: comment.user
  end
end
