require "spec_helper"

describe Notification do
  describe ".open_tasks" do
    it "counts open_tasks" do
      2.times { create :open_task }
      create :closed_task
      create :completed_task

      expect(Notification.open_tasks.count).to eq 2
    end
  end

  describe ".unreviewed_references" do
    it "counts unreviewed_references" do
      create :article_reference, review_state: "reviewing"
      create :article_reference, review_state: "reviewed"

      expect(Notification.unreviewed_references.count).to eq 1
    end
  end
end
