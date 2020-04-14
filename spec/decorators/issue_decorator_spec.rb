# frozen_string_literal: true

require 'rails_helper'

describe IssueDecorator do
  describe '#help_wanted_badge' do
    context "when issue does not have `help_wanted` checked" do
      let(:issue) { build_stubbed(:issue).decorate }

      specify { expect(issue.help_wanted_badge).to eq nil }
    end

    context "when issue has `help_wanted` checked" do
      context 'when issue is open' do
        let(:issue) { build_stubbed(:issue, :open, :help_wanted).decorate }

        specify do
          expect(issue.help_wanted_badge).
            to eq '<span class="rounded-badge high-priority-label">Help wanted!</span>'
        end
      end

      context 'when issue is closed' do
        let(:issue) { build_stubbed(:issue, :closed, :help_wanted).decorate }

        specify { expect(issue.help_wanted_badge).to eq nil }
      end
    end
  end
end
