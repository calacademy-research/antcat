# frozen_string_literal: true

require 'rails_helper'

describe Feedback do
  it { is_expected.to be_versioned }

  describe 'validations' do
    it { is_expected.to validate_presence_of :comment }
    it { is_expected.to validate_length_of(:comment).is_at_most(described_class::COMMENT_MAX_LENGTH) }
    it { is_expected.to validate_length_of(:name).is_at_most(described_class::NAME_MAX_LENGTH) }
    it { is_expected.to validate_length_of(:email).is_at_most(described_class::EMAIL_MAX_LENGTH) }

    it "shortens a long page instead of rejecting the feedback" do
      feedback = build :feedback, page: "/catalog/1?#{'x' * 500}"

      expect(feedback).to be_valid
      expect(feedback.page.length).to eq described_class::PAGE_MAX_LENGTH
    end
  end

  describe ".submitted_by_ip" do
    let!(:ip) { "255.255.255.255" }
    let!(:feedback) { create :feedback, ip: ip }

    before do
      create :feedback
    end

    specify { expect(described_class.submitted_by_ip(ip)).to eq [feedback] }
  end

  describe "open/closed" do
    describe "#close!" do
      let(:feedback) { create :feedback }

      it "closes the feedback" do
        expect { feedback.close! }.to change { feedback.closed? }.to(true)
      end
    end

    describe "#reopen!" do
      let(:feedback) { create :feedback, :closed }

      it "reopens the feedback" do
        expect { feedback.reopen! }.to change { feedback.closed? }.to(false)
      end
    end
  end
end
