require 'rails_helper'

describe User do
  it { is_expected.to be_versioned }

  describe 'relations' do
    it { is_expected.to have_many(:activities).dependent(:restrict_with_error) }
    it { is_expected.to have_many(:comments).dependent(:restrict_with_error) }
    it { is_expected.to have_many(:notifications).dependent(:restrict_with_error) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of :name }
    it { is_expected.to_not allow_values('<', '>').for(:name) }

    describe "uniqueness validation" do
      subject { create :user }

      it { is_expected.to validate_uniqueness_of(:name).ignoring_case_sensitivity }
    end
  end

  describe '#unconfirmed?' do
    specify { expect(build_stubbed(:user)).to be_unconfirmed }
    specify { expect(build_stubbed(:user, :helper)).to_not be_unconfirmed }
    specify { expect(build_stubbed(:user, :editor)).to_not be_unconfirmed }
  end

  describe '#remaining_edits_for_unconfirmed_user' do
    let!(:user) { create :user }

    context 'when user has no activities' do
      specify { expect(user.remaining_edits_for_unconfirmed_user).to eq User::UNCONFIRMED_USER_EDIT_LIMIT_COUNT }
    end

    context 'when user has recent activity' do
      it 'counts an activity as an edit' do
        expect { create :activity, user: user }.
          to change { user.remaining_edits_for_unconfirmed_user }.by(-1)
      end

      it 'does not count submitted feedbacks towards the limit' do
        expect { create :activity, user: user, trackable: create(:feedback) }.
          to_not change { user.remaining_edits_for_unconfirmed_user }
      end
    end
  end

  describe "#notify_because" do
    let(:user) { create :user }
    let(:notifier) { create :user }
    let(:issue) { create :issue }

    context "when user and notifier are the same" do
      it "doesn't create a notification" do
        expect do
          user.notify_because Notification::CREATOR_OF_COMMENTABLE, attached: issue, notifier: user
        end.not_to change { Notification.count }
      end
    end

    context "when user has already been notified for that attached/notifier combination" do
      it "doesn't create a notification" do
        user.notify_because Notification::CREATOR_OF_COMMENTABLE, attached: issue, notifier: notifier

        expect do
          user.notify_because Notification::CREATOR_OF_COMMENTABLE, attached: issue, notifier: notifier
        end.not_to change { Notification.count }
      end
    end

    it "*test the above shaky examples that may fail for other reasons*" do
      expect do
        user.notify_because Notification::CREATOR_OF_COMMENTABLE, attached: issue, notifier: notifier
      end.to change { Notification.count }.by 1
    end
  end

  describe "#mark_unseen_notifications_as_seen" do
    let!(:user) { create :user }

    before do
      create :notification, :unread, user: user
    end

    specify do
      expect { user.mark_unseen_notifications_as_seen }.
        to change { user.unseen_notifications.count }.from(1).to(0)
    end
  end
end
