# frozen_string_literal: true

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
    it { is_expected.not_to allow_values('<', '>').for(:name) }

    describe "uniqueness validation" do
      subject { create :user }

      it { is_expected.to validate_uniqueness_of(:name).ignoring_case_sensitivity }
    end
  end

  describe "#valid_for_authentication?" do
    specify { expect(build_stubbed(:user).active_for_authentication?).to eq true }
    specify { expect(build_stubbed(:user, locked: true).active_for_authentication?).to eq false }
    specify { expect(build_stubbed(:user, deleted: true).active_for_authentication?).to eq false }
  end

  describe '#unconfirmed?' do
    specify { expect(build_stubbed(:user).unconfirmed?).to eq true }
    specify { expect(build_stubbed(:user, :helper).unconfirmed?).to eq false }
    specify { expect(build_stubbed(:user, :editor).unconfirmed?).to eq false }
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
    end
  end

  describe "#mark_all_notifications_as_seen" do
    let!(:user) { create :user }

    before do
      create :notification, :unread, user: user
    end

    specify do
      expect { user.mark_all_notifications_as_seen }.
        to change { user.unseen_notifications.count }.from(1).to(0)
    end
  end
end
