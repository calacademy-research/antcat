require "spec_helper"

describe Notification do
  describe ".pending_count" do
    it "counts open_tasks" do
      2.times { create :open_task }
      create :closed_task
      create :completed_task

      expect(Notification.pending_count(:open_tasks)).to eq 2
    end

    it "counts unreviewed_references" do
      create :article_reference, review_state: "reviewing"
      create :article_reference, review_state: "reviewed"

      expect(Notification.pending_count(:unreviewed_references)).to eq 1
    end

    it "counts unreviewed_catalog_changes" do
      # TODO
    end

    it "counts :all / all_pending_actions_count" do
      # TODO
    end
  end
end
