require "spec_helper"

describe Issue do
  it { should be_versioned }
  it { should validate_presence_of :title }
  it { should validate_presence_of :description }
  it { should validate_inclusion_of(:status).in_array %w(open closed completed) }
  it { should validate_length_of(:title).is_at_most 70 }

  describe "scopes" do
    describe ".open and .non_open" do
      let!(:open) { create :issue }
      let!(:also_open) { create :issue }
      let!(:completed) { create :completed_issue }
      let!(:closed) { create :closed_issue }

      it "open returns open issues" do
        expect(Issue.open).to eq [open, also_open]
      end

      it "non_open returns completed and closed issues" do
        expect(Issue.non_open).to eq [completed, closed]
      end
    end

    describe ".by_status_and_date" do
      let!(:first) { create :issue, created_at: Time.now + 10.days }
      let!(:second) { create :issue }
      let!(:third) { create :completed_issue, created_at: Time.now + 7.days }
      let!(:fourth) { create :closed_issue, created_at: Time.now + 3.days }
      let!(:fifth) { create :completed_issue, created_at: Time.now - 10.days }

      it "orders open issue first, then by creation date" do
        expect(Issue.by_status_and_date)
          .to eq [first, second, third, fourth, fifth]
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
