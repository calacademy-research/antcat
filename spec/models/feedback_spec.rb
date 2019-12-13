require 'rails_helper'

describe Feedback do
  it { is_expected.to validate_presence_of :comment }

  describe ".submitted_by_ip" do
    let!(:ip) { "255.255.255.255" }
    let!(:feedback) { create :feedback, ip: ip }

    before do
      create :feedback
    end

    specify { expect(described_class.submitted_by_ip(ip)).to eq [feedback] }
  end

  describe "open/closed" do
    describe "#close" do
      let(:open) { create :feedback }

      it "closes the feedback item" do
        open.close
        expect(open.closed?).to be true
      end
    end

    describe "#reopen" do
      let(:closed) { create :feedback, open: false }

      it "reopens the feedback item" do
        closed.reopen
        expect(closed.closed?).to be false
      end
    end
  end
end
