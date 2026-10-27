# frozen_string_literal: true

require 'rails_helper'

describe Taxa::BuildTaxon do
  describe "#call" do
    it "refuses classes that are not ranks" do
      expect { described_class['User', create(:subfamily)] }.to raise_error(ArgumentError)
    end

    context 'when `rank_to_create` is `Rank::GENUS`' do
      let(:parent) { create :subfamily }

      it 'returns a `Genus`' do
        expect(described_class[Rank::GENUS, parent]).to be_a Genus
      end

      it 'builds a `GenusName` for the taxon' do
        expect(described_class[Rank::GENUS, parent].name).to be_a GenusName
      end
    end
  end
end
