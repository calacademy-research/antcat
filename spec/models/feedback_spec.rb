require 'spec_helper'

describe Feedback do
  it { is_expected.to validate_presence_of :comment }

  describe "#from_the_same_ip" do
    let!(:feedback) { build_stubbed :feedback, ip: "255.255.255.255" }

    before do
      create :feedback
      create :feedback, ip: "255.255.255.255"
    end

    it "returns feedbacks from the same IP" do
      expect(feedback.from_the_same_ip.count).to eq 1
    end
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
