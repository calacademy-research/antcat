# frozen_string_literal: true

require 'rails_helper'

describe Users::Notify do
  describe '#call' do
    let(:user) { create :user }
    let(:attached) { create :comment }
    let(:notifier) { attached.user }

    it "creates a notification" do
      expect do
        described_class[user, Notification::CREATOR_OF_COMMENTABLE, attached: attached, notifier: notifier]
      end.to change { user.notifications.count }.by(1)

      notification = user.notifications.last
      expect(notification.reason).to eq Notification::CREATOR_OF_COMMENTABLE
      expect(notification.attached).to eq attached
      expect(notification.notifier).to eq notifier
    end

    it 'sends an email notification' do
      expect(UserMailer).to receive(:new_notification).
        with(user, kind_of(Notification)).and_call_original
      described_class[user, Notification::CREATOR_OF_COMMENTABLE, attached: attached, notifier: notifier]
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
        user.notifications.create!(
          reason: Notification::CREATOR_OF_COMMENTABLE,
          attached: attached,
          notifier: notifier
        )
      end

      it "doesn't create a notification" do
        expect do
          described_class[user, Notification::CREATOR_OF_COMMENTABLE, attached: attached, notifier: notifier]
        end.not_to change { Notification.count }
      end
    end
  end
end
