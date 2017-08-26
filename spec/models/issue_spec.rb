require "spec_helper"

describe Issue do
  it { should be_versioned }
  it { should validate_presence_of :title }
  it { should validate_presence_of :description }
  it { should validate_length_of(:title).is_at_most 70 }

  describe "scopes" do
    describe ".by_status_and_date" do
      let!(:expected_order) do
        travel_to Time.new(2010)
        fourth = create :issue, :closed

        travel_to Time.new(2015)
        second = create :issue, :open

        travel_to Time.new(2017)
        first = create :issue, :open

        travel_to Time.new(2016)
        third = create :issue, :closed

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
