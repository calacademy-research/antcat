# frozen_string_literal: true

require 'rails_helper'

describe DatabaseScripts::ReplacementNameHistoryItemsMissing do
  let(:script) { described_class.new }

  context "with results" do
    let!(:taxon) { create :subfamily, :homonym }

    specify { expect(script.results).to eq [taxon] }

    it_behaves_like "a database script with renderable results"
  end

  context "without results" do
    let!(:taxon) { create :subfamily, :homonym }

    before do
      create :history_item, :replacement_name, protonym: taxon.protonym
    end

    specify { expect(script.results).to eq [] }
  end
end
