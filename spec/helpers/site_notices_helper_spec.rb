require "spec_helper"

describe SiteNoticesHelper do
  describe "#most_recent_site_notice_already_dismissed?" do
    def dismissed? last_dismissed_id
      helper.send :most_recent_site_notice_already_dismissed?, last_dismissed_id
    end

    context "when there are site notices" do
      let!(:site_notice) { create :site_notice }

      context "when session variable is blank" do
        specify { expect(dismissed?(nil)).to be false }
      end

      context "when session variable is present" do
        let!(:last_site_notice_id) { SiteNotice.last.try :id }

        context "when session variable is lower than the last notice" do
          specify { expect(dismissed?(last_site_notice_id - 1)).to be false }
        end

        context "when session variable is same as the last notice" do
          specify { expect(dismissed?(last_site_notice_id)).to be true }
        end

        context "when session variable is higher than the last notice (this cannot happen)" do
          specify { expect(dismissed?(last_site_notice_id + 1)).to be true }
        end
      end
    end

    context "there are no site notices in the whole database" do
      context "when session variable is blank" do
        specify { expect(dismissed?(nil)).to be false }
      end

      context "when session variable is present" do
        specify { expect(dismissed?(999)).to be false }
      end
    end
  end
end
