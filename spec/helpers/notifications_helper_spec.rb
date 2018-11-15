require 'spec_helper'

describe NotificationsHelper do
  describe "#thing_link_label" do
    context "when `thing` is an `Issue`" do
      let(:issue) { build_stubbed :issue }

      specify { expect(helper.thing_link_label(issue)).to eq issue.title }
    end

    context "when `thing` is a `SiteNotice`" do
      let(:site_notice) { build_stubbed :site_notice }

      specify { expect(helper.thing_link_label(site_notice)).to eq site_notice.title }
    end

    context "when `thing` is a `Feedback`" do
      let(:feedback) { build_stubbed :feedback }

      specify { expect(helper.thing_link_label(feedback)).to eq "feedback ##{feedback.id}" }
    end
  end
end
