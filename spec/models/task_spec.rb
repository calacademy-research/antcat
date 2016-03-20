require "spec_helper"

describe Task do
  it { should validate_presence_of(:title) }
  it { should validate_presence_of(:description) }
  it { should validate_inclusion_of(:status).in_array %w(open closed completed) }

  describe "scopes" do
    describe "open and non_open" do
      let!(:open) { create :task }
      let!(:also_open) { create :task }
      let!(:completed) { create :completed_task }
      let!(:closed) { create :closed_task }

      it "open returns open tasks" do
        expect(Task.open).to eq [open, also_open]
      end

      it "non_open returns completed and closed tasks" do
        expect(Task.non_open).to eq [completed, closed]
      end
    end

    describe "by_status_and_date" do
      let!(:first) { create :task, created_at: Time.now + 10.days }
      let!(:second) { create :task }
      let!(:third) { create :completed_task, created_at: Time.now + 7.days }
      let!(:fourth) { create :closed_task, created_at: Time.now + 3.days }
      let!(:fifth) { create :completed_task, created_at: Time.now - 10.days }

      it "orders open task first, then by creation date" do
        expect(Task.by_status_and_date)
          .to eq [first, second, third, fourth, fifth]
      end
    end
  end

  describe "predicate methods" do
    let(:open) { create :task }
    let(:completed) { create :completed_task }
    let(:closed) { create :closed_task }

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
      open = create :task
      open.set_status(:closed, user)
      expect(open.status).to eq "closed"
    end

    it "closed to open" do
      closed = create :closed_task
      closed.set_status(:open, user)
      expect(closed.status).to eq "open"
    end
  end
end
