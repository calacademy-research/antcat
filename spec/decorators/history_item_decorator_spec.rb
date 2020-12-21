# frozen_string_literal: true

require 'rails_helper'

describe HistoryItemDecorator do
  subject(:decorated) { history_item.decorate }

  describe "#rank_specific_badge" do
    context "when history item is not rank-specific" do
      let(:history_item) { build_stubbed :history_item }

      specify { expect(decorated.rank_specific_badge).to eq nil }
    end

    context "when history item is rank-specific" do
      let(:history_item) { build_stubbed :history_item, :family_rank_only_item }

      specify do
        expect(decorated.rank_specific_badge).to eq <<~HTML.strip
          <span class="logged-in-only-background"><small class="bold-notice">Family-only item</small></span>
        HTML
      end
    end
  end
end
