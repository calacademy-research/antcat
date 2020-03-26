# frozen_string_literal: true

require 'rails_helper'

describe Taxa::BuildTaxon do
  describe "#call" do
    context 'when `rank_to_create` is "Genus"' do
      let(:parent) { create :subfamily }

      it 'returns a `Genus`' do
        expect(described_class["Genus", parent]).to be_a Genus
      end

      it 'builds a `GenusName` for the taxon' do
        expect(described_class["Genus", parent].name).to be_a GenusName
      end
    end
  end
end
