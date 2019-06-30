require 'spec_helper'

describe Taxa::Search::QuickSearch do
  describe "#call" do
    let!(:rufa) do
      create :species, name_string: 'Monoceros rufa', genus: create(:genus, name_string: 'Monoceros')
    end
    let!(:monomorium) { create :genus, name_string: 'Monomorium' }

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
      lepti = create :subfamily, name_string: "Lepti"
      lepta = create :subfamily, name_string: "Lepta"
      lepte = create :subfamily, name_string: "Lepte"

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
