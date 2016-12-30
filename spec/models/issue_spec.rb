require "spec_helper"

describe Issue do
  it { should be_versioned }
  it { should validate_presence_of :title }
  it { should validate_presence_of :description }
  it { should validate_inclusion_of(:status).in_array %w(open closed completed) }
  it { should validate_length_of(:title).is_at_most 70 }

  describe "scopes" do
    describe ".by_status_and_date" do
      let!(:expected_order) do
        travel_to Time.new(2010)
        fourth = create :closed_issue

        travel_to Time.new(2015)
        second = create :open_issue

        travel_to Time.new(2017)
        first = create :open_issue

        travel_to Time.new(2016)
        third = create :closed_issue

        [first, second, third, fourth]
      end

      it "orders open issue first, then by creation date" do
        expect(Issue.by_status_and_date).to eq expected_order
      end
    end
  end

  describe "predicate methods" do
    let(:open) { build_stubbed :issue }
    let(:completed) { build_stubbed :completed_issue }
    let(:closed) { build_stubbed :closed_issue }

    it "#open?" do
      expect(open.open?).to be true
      expect(completed.open?).to be false
      expect(closed.open?).to be false
    end

    it "#archived?" do
      expect(open.archived?).to be false
      expect(completed.archived?).to be true
      expect(closed.archived?).to be true
    end
  end

  describe "#set_status" do
    let(:user) { create :user }

    it "open to closed" do
      open = create :issue
      open.set_status :closed, user
      expect(open.status).to eq "closed"
    end

    it "closed to open" do
      closed = create :closed_issue
      closed.set_status :open, user
      expect(closed.status).to eq "open"
    end
  end
end
