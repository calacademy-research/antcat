# frozen_string_literal: true

require 'rails_helper'

describe DatabaseScripts::HistoryItemsWithPagesContainingWeirdCharacters do
  let(:script) { described_class.new }

  context "with results" do
    let!(:weird_item) { create :history_item, :lectotype_designation }
    let!(:normal_item) { create :history_item, :lectotype_designation }

    before do
      weird_item.update_columns(pages: '12*')
      normal_item.update_columns(pages: '12-14, (fig. 3).')
    end

    it "reports pages with characters outside the allowed set, but not hyphens" do
      expect(script.results).to eq [weird_item]
    end

    it_behaves_like "a database script with renderable results"
  end
end
