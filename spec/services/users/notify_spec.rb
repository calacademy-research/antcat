require 'rails_helper'

describe Users::Notify do
  describe '#call' do
    let(:user) { create :user }
    let(:attached) { create :issue }
    let(:notifier) { create :user }

    it "created a notification" do
      expect do
        described_class[user, Notification::CREATOR_OF_COMMENTABLE, attached: attached, notifier: notifier]
      end.to change { user.notifications.count }.by(1)

      notification = user.notifications.last
      expect(notification.reason).to eq Notification::CREATOR_OF_COMMENTABLE
      expect(notification.attached).to eq attached
      expect(notification.notifier).to eq notifier
    end

    context "when user and notifier are the same" do
      it "doesn't create a notification" do
        expect do
          described_class[user, Notification::CREATOR_OF_COMMENTABLE, attached: attached, notifier: user]
        end.not_to change { Notification.count }
      end
    end

    context "when user has not already been notified for that attached/notifier combination" do
      before do
        described_class[user, Notification::CREATOR_OF_COMMENTABLE, attached: attached, notifier: notifier]
      end

      it "doesn't create a notification" do
        expect do
          described_class[user, Notification::CREATOR_OF_COMMENTABLE, attached: attached, notifier: notifier]
        end.not_to change { Notification.count }
      end
    end
  end
end
