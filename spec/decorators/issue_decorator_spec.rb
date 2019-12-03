require 'rails_helper'

describe IssueDecorator do
  let(:open_issue) { build_stubbed(:issue, :open).decorate }
  let(:closed_issue) { build_stubbed(:issue, :closed).decorate }

  describe "#format_status" do
    specify { expect(open_issue.format_status).to eq "Open" }
    specify { expect(closed_issue.format_status).to eq "Closed" }
  end

  describe "#format_status_css" do
    specify { expect(open_issue.format_status_css).to eq "open" }
    specify { expect(closed_issue.format_status_css).to eq "closed" }
  end
end
