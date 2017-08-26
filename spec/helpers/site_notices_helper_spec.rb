require "spec_helper"

describe SiteNoticesHelper do
  describe "#most_recent_site_notice_already_dismissed?" do
    def dismissed? last_dismissed_id
      helper.send :most_recent_site_notice_already_dismissed?, last_dismissed_id
    end

    context "there are site notices" do
      let!(:site_notice) { create :site_notice }

      context "session variable is blank" do
        specify { expect(dismissed? nil).to be_falsey }
      end

      context "session variable is present" do
        let!(:last_site_notice_id) { SiteNotice.last.try :id }

        context "session variable lower than the last notice" do
          specify { expect(dismissed? last_site_notice_id - 1).to be_falsey }
        end

        context "session variable same as the last notice" do
          specify { expect(dismissed? last_site_notice_id).to be true }
        end

        context "session variable higher than the last notice (this cannot happen)" do
          specify { expect(dismissed? last_site_notice_id + 1).to be true }
        end
      end
    end

    context "there are no site notices in the whole database" do
      context "session variable is blank" do
        specify { expect(dismissed? nil).to be_falsey }
      end

      context "session variable present" do
        specify { expect(dismissed? 999).to be_falsey }
      end
    end
  end
end
