# frozen_string_literal: true

require 'rails_helper'

describe DatabaseScripts::NonRelationalFormDescriptionsHistoryItems do
  let(:script) { described_class.new }

  context "with results" do
    let!(:history_item_1) { create :history_item, :taxt, taxt: "#{Taxt.ref(1)}: 2 (w.)" }
    let!(:history_item_2) { create :history_item, :taxt, taxt: "#{Taxt.ref(1)}: 2, 3 (w.)" }

    specify { expect(script.results).to match_array [history_item_1, history_item_2] }

    it_behaves_like "a database script with renderable results"
  end

  context "without results" do
    let!(:history_item) { create :history_item, :taxt }

    specify { expect(script.results).to eq [] }
  end
end
