require "spec_helper"

describe Issue do
  it { is_expected.to be_versioned }
  it { is_expected.to validate_presence_of :title }
  it { is_expected.to validate_presence_of :description }
  it { is_expected.to validate_length_of(:title).is_at_most 70 }

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
