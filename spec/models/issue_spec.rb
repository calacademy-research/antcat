# frozen_string_literal: true

require 'rails_helper'

describe Issue do
  it { is_expected.to be_versioned }

  describe 'relations' do
    it { is_expected.to belong_to(:user).required }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of :title }
    it { is_expected.to validate_length_of(:title).is_at_most(described_class::TITLE_MAX_LENGTH) }
    it { is_expected.to validate_presence_of :description }
  end

  describe "scopes" do
    describe ".by_status_and_date" do
      include ActiveSupport::Testing::TimeHelpers

      let!(:expected_order) do
        fourth = travel_to(5.years.ago) { create :issue, :closed }
        second = travel_to(2.years.ago) { create :issue, :open }
        first = travel_to(Time.current) { create :issue, :open }
        third = travel_to(1.year.ago) { create :issue, :closed }

        [first, second, third, fourth]
      end

      it "orders open issue first, then by creation date" do
        expect(described_class.by_status_and_date).to eq expected_order
      end
    end
  end

  describe '.help_wanted?' do
    context 'when there are no issues with `help_wanted` checked' do
      before do
        create :issue, :open
        create :issue, :closed
      end

      specify { expect(described_class.help_wanted?).to eq false }
    end

    context 'when there are issues with `help_wanted` checked' do
      context 'when at least one issue is open' do
        before { create :issue, :open, :help_wanted }

        specify { expect(described_class.help_wanted?).to eq true }
      end

      context 'when no issue is open' do
        before { create :issue, :closed, :help_wanted }

        specify { expect(described_class.help_wanted?).to eq false }
      end
    end
  end

  describe "closing and re-opening" do
    describe "#close!" do
      let(:issue) { create :issue, :open }
      let(:user) { create :user }

      it "sets open to false" do
        expect { issue.close! user }.to change { issue.open? }.from(true).to(false)
      end

      it "sets the closer to the supplied user" do
        expect { issue.close! user }.to change { issue.closer }.from(nil).to(user)
      end
    end

    describe "#reopen!" do
      let(:issue) { create :issue, :closed }

      it "sets open to true" do
        expect { issue.reopen! }.to change { issue.open? }.from(false).to(true)
      end

      it "sets the closer to nil" do
        expect { issue.reopen! }.to change { issue.closer }.to(nil)
      end
    end
  end
end
