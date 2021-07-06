# frozen_string_literal: true

require 'rails_helper'

describe DatabaseScripts::ExtantTaxaInFossilGenera do
  let(:script) { described_class.new }

  context "with results" do
    let!(:taxon) do
      fossil_genus = create :genus, protonym: create(:protonym, :genus_group, :fossil)
      create :species, genus: fossil_genus
    end

    specify { expect(script.results).to eq [taxon] }

    it_behaves_like "a database script with renderable results"
  end

  context "without results" do
    let!(:taxon) { create :species }

    specify { expect(script.results).to eq [] }
  end
end
