# frozen_string_literal: true

require 'rails_helper'

describe ConvertToSubspeciesPolicy do
  subject(:policy) { described_class.new(taxon) }

  context "when taxon is not a species" do
    let(:taxon) { create :family }

    specify do
      expect(policy.allowed?).to eq false
      expect(policy.errors).to include "taxon is not a species"
    end
  end

  context "when taxon has subspecies" do
    let(:taxon) { create :species }

    before do
      create :subspecies, species: taxon
    end

    specify do
      expect(policy.allowed?).to eq false
      expect(policy.errors).to include "taxon has subspecies"
    end
  end
end
