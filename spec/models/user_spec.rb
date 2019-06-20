require 'spec_helper'

describe User do
  it { is_expected.to be_versioned }

  describe 'validations' do
    it { is_expected.to validate_presence_of :name }

    describe "uniqueness validation" do
      subject { create :user }

      it { is_expected.to validate_uniqueness_of :name }
    end
  end

  describe '#unconfirmed?' do
    specify { expect(build_stubbed(:user)).to be_unconfirmed }
    specify { expect(build_stubbed(:user, :helper)).to_not be_unconfirmed }
    specify { expect(build_stubbed(:user, :editor)).to_not be_unconfirmed }
  end

  describe "#notify_because" do
    let(:user) { create :user }
    let(:notifier) { create :user }
    let(:issue) { create :issue }

    context "when user and notifier are the same" do
      it "doesn't create a notification" do
        expect do
          user.notify_because :mentioned_in_thing, attached: issue, notifier: user
        end.not_to change { Notification.count }
      end
    end

    context "when user has already been notified for that attached/notifier combination" do
      it "doesn't create a notification" do
        user.notify_because :mentioned_in_thing, attached: issue, notifier: notifier

        expect do
          user.notify_because :mentioned_in_thing, attached: issue, notifier: notifier
        end.not_to change { Notification.count }
      end
    end

    it "*test the above shaky examples that may fail for other reasons*" do
      expect do
        user.notify_because :mentioned_in_thing, attached: issue, notifier: notifier
      end.to change { Notification.count }.by 1
    end
  end

  describe "#mark_unseen_notifications_as_seen" do
    let!(:user) { create :user }
    let!(:notification) { create :notification, :unread, user: user }

    specify do
      expect { user.mark_unseen_notifications_as_seen }.
        to change { user.unseen_notifications.count }.from(1).to(0)
    end
  end

  describe "#already_notified_for_attached_by_user?" do
    let(:user) { create :user }
    let(:notifier) { create :user }
    let(:issue) { create :issue }

    it "can tell" do
      expect { user.notify_because :mentioned_in_thing, attached: issue, notifier: notifier }.
        to change { user.send :already_notified_for_attached_by_user?, issue, notifier }.
        from(false).to(true)
    end
  end
end
