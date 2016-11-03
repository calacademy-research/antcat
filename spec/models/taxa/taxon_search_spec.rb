require 'spec_helper'

describe Taxon do
  describe ".find_by_name" do
    it "returns nil if nothing matches" do
      expect(Taxon.find_by_name('sdfsdf')).to eq nil
    end

    it "returns one of the items if there are more than one (bad!)" do
      name = create :genus_name, name: 'Monomorium'
      2.times { create :genus, name: name }
      expect(Taxon.find_by_name('Monomorium').name.name).to eq 'Monomorium'
    end
  end

  describe ".quick_search" do
    let!(:rufa) do
      create :species,
        genus: create(:genus, name: create(:genus_name, name: 'Monoceros')),
        name: create(:species_name, name: 'Monoceros rufa', epithet: 'rufa')
    end
    before { create :genus, name: create(:genus_name, name: 'Monomorium') }

    it "returns [] if nothing matches" do
      results = Taxa::Search.quick_search 'sdfsdf'
      expect(results).to eq []
    end

    it "returns exact matches" do
      results = Taxa::Search.quick_search 'Monomorium'
      expect(results.first.name.to_s).to eq 'Monomorium'
    end

    it "can search by prefix" do
      results = Taxa::Search.quick_search 'Monomor', search_type: 'beginning_with'
      expect(results.first.name.to_s).to eq 'Monomorium'
    end

    it "matches substrings" do
      results = Taxa::Search.quick_search 'iu', search_type: 'containing'
      expect(results.first.name.to_s).to eq 'Monomorium'
    end

    it "returns multiple matches" do
      results = Taxa::Search.quick_search 'Mono', search_type: 'containing'
      expect(results.size).to eq 2
    end

    it "only returns subfamilies, tribes, genera, subgenera, species, and subspecies" do
      create_subfamily 'Lepto'
      create_tribe 'Lepto1'
      create_genus 'Lepto2'
      create_subgenus 'Lepto3'
      create_species 'Lepto4'
      create_subspecies 'Lepto5'

      results = Taxa::Search.quick_search 'Lepto', search_type: 'beginning_with'
      expect(results.size).to eq 6
    end

    it "sorts results by name" do
      %w(Lepti Lepta Lepte).each do |name|
        create :subfamily, name: create(:name, name: name)
      end

      results = Taxa::Search.quick_search 'Lept', search_type: 'beginning_with'
      expect(results.map(&:name).map(&:to_s)).to eq ['Lepta', 'Lepte', 'Lepti']
    end

    describe "Finding full species name" do
      it "searches for full species names" do
        results = Taxa::Search.quick_search 'Monoceros rufa '
        expect(results.first).to eq rufa
      end

      it "searches for whole names, even when using beginning with, even with trailing space" do
        results = Taxa::Search.quick_search 'Monoceros rufa ', search_type: 'beginning_with'
        expect(results.first).to eq rufa
      end

      it "searches for partial species names" do
        results = Taxa::Search.quick_search 'Monoceros ruf', search_type: 'beginning_with'
        expect(results.first).to eq rufa
      end
    end
  end
end
