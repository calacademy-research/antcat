require 'spec_helper'

describe Feedback do
  it { is_expected.to validate_presence_of :comment }

  describe "scopes" do
    describe ".recently_created" do
      before do
        create :feedback
        create :feedback, created_at: (Time.now - 8.minutes)
        create :feedback, created_at: (Time.now - 3.days)
      end

      it "defaults to 5 minutes" do
        expect(described_class.recently_created.count).to eq 1
      end

      it "accepts any value" do
        expect(described_class.recently_created(10.minutes.ago).count).to eq 2
        expect(described_class.recently_created(7.days.ago).count).to eq 3
      end
    end
  end

  describe "#from_the_same_ip" do
    let!(:feedback) { create :feedback }

    before do
      create :feedback
      create :feedback, ip: "255.255.255.255"
    end

    it "returns feedbacks from the same IP" do
      expect(feedback.from_the_same_ip.count).to eq 2
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
