require 'spec_helper'

describe Taxa::QuickSearch do
  describe "#call" do
    let!(:rufa) do
      create :species,
        genus: create(:genus, name: create(:genus_name, name: 'Monoceros')),
        name: create(:species_name, name: 'Monoceros rufa', epithet: 'rufa')
    end
    let!(:monomorium) { create :genus, name: create(:genus_name, name: 'Monomorium') }

    it "returns an empty array if nothing matches" do
      expect(described_class['sdfsdf']).to eq []
    end

    it "returns exact matches" do
      expect(described_class['Monomorium']).to eq [monomorium]
    end

    it "can search by prefix" do
      expect(described_class['Monomor', search_type: 'beginning_with']).to eq [monomorium]
    end

    it "matches substrings" do
      expect(described_class['iu', search_type: 'containing']).to eq [monomorium]
    end

    it "returns multiple matches" do
      expect(described_class['Mono', search_type: 'containing']).
        to match_array [rufa.genus, monomorium]
    end

    it "sorts results by name" do
      lepti = create :subfamily, name: create(:name, name: "Lepti")
      lepta = create :subfamily, name: create(:name, name: "Lepta")
      lepte = create :subfamily, name: create(:name, name: "Lepte")

      expect(described_class['Lept', search_type: 'beginning_with']).to eq [lepta, lepte, lepti]
    end

    describe "Finding full species name" do
      it "searches for full species names" do
        expect(described_class['Monoceros rufa ']).to eq [rufa]
      end

      it "searches for whole names, even when using beginning with, even with trailing space" do
        expect(described_class['Monoceros rufa ', search_type: 'beginning_with']).to eq [rufa]
      end

      it "searches for partial species names" do
        expect(described_class['Monoceros ruf', search_type: 'beginning_with']).to eq [rufa]
      end
    end
  end
end
