require 'spec_helper'

describe Taxa::QuickSearch do
  describe "#call" do
    let!(:rufa) do
      create :species,
        genus: create(:genus, name: create(:genus_name, name: 'Monoceros')),
        name: create(:species_name, name: 'Monoceros rufa', epithet: 'rufa')
    end

    before { create :genus, name: create(:genus_name, name: 'Monomorium') }

    it "returns [] if nothing matches" do
      results = described_class.new('sdfsdf').call
      expect(results).to eq []
    end

    it "returns exact matches" do
      results = described_class.new('Monomorium').call
      expect(results.first.name.to_s).to eq 'Monomorium'
    end

    it "can search by prefix" do
      results = described_class.new('Monomor', search_type: 'beginning_with').call
      expect(results.first.name.to_s).to eq 'Monomorium'
    end

    it "matches substrings" do
      results = described_class.new('iu', search_type: 'containing').call
      expect(results.first.name.to_s).to eq 'Monomorium'
    end

    it "returns multiple matches" do
      results = described_class.new('Mono', search_type: 'containing').call
      expect(results.size).to eq 2
    end

    it "only returns subfamilies, tribes, genera, subgenera, species, and subspecies" do
      create_subfamily 'Lepto'
      create_tribe 'Lepto1'
      create_genus 'Lepto2'
      create_subgenus 'Lepto3'
      create_species 'Lepto4'
      create_subspecies 'Lepto5'

      results = described_class.new('Lepto', search_type: 'beginning_with').call
      expect(results.size).to eq 6
    end

    it "sorts results by name" do
      lepti = create :subfamily, name: create(:name, name: "Lepti")
      lepta = create :subfamily, name: create(:name, name: "Lepta")
      lepte = create :subfamily, name: create(:name, name: "Lepte")

      results = described_class.new('Lept', search_type: 'beginning_with').call
      expect(results).to eq [lepta, lepte, lepti]
    end

    describe "Finding full species name" do
      it "searches for full species names" do
        results = described_class.new('Monoceros rufa ').call
        expect(results.first).to eq rufa
      end

      it "searches for whole names, even when using beginning with, even with trailing space" do
        results = described_class.new('Monoceros rufa ', search_type: 'beginning_with').call
        expect(results.first).to eq rufa
      end

      it "searches for partial species names" do
        results = described_class.new('Monoceros ruf', search_type: 'beginning_with').call
        expect(results.first).to eq rufa
      end
    end
  end
end
