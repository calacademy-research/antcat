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

  describe "#find_epithet_in_genus" do
    it "returns nil if nothing matches" do
      expect(Taxa::Utility.find_epithet_in_genus('sdfsdf', create_genus)).to eq nil
    end

    it "returns the one item" do
      species = create_species 'Atta serratula'
      expect(Taxa::Utility.find_epithet_in_genus('serratula', species.genus)).to eq [species]
    end

    context "mandatory spelling changes" do
      it "finds -a when asked to find -us" do
        species = create_species 'Atta serratula'
        expect(Taxa::Utility.find_epithet_in_genus('serratulus', species.genus)).to eq [species]
      end
    end
  end

  describe "#find_name" do
    before do
      create :genus, name: create(:genus_name, name: 'Monomorium')
      @monoceros = create :genus, name: create(:genus_name, name: 'Monoceros')
      species_name = create :species_name, name: 'Monoceros rufa', epithet: 'rufa'
      @rufa = create :species, genus: @monoceros, name: species_name
    end

    it "returns [] if nothing matches" do
      expect(Taxa::Search.find_name('sdfsdf')).to eq []
    end

    it "returns an exact matches" do
      expect(Taxa::Search.find_name('Monomorium').first.name.to_s).to eq 'Monomorium'
    end

    it "should return a prefix match" do
      expect(Taxa::Search.find_name('Monomor', 'beginning_with').first.name.to_s).to eq 'Monomorium'
    end

    it "should return a substring match" do
      expect(Taxa::Search.find_name('iu', 'containing').first.name.to_s).to eq 'Monomorium'
    end

    it "returns multiple matches" do
      results = Taxa::Search.find_name 'Mono', 'containing'
      expect(results.size).to eq 2
    end

    it "should not return anything but subfamilies, tribes, genera, subgenera, species,and subspecies" do
      create_subfamily 'Lepto'
      create_tribe 'Lepto1'
      create_genus 'Lepto2'
      create_subgenus 'Lepto3'
      create_species 'Lepto4'
      create_subspecies 'Lepto5'

      results = Taxa::Search.find_name 'Lepto', 'beginning_with'
      expect(results.size).to eq 6
    end

    it "sorts results by name" do
      create :subfamily, name: create(:name, name: 'Lepti')
      create :subfamily, name: create(:name, name: 'Lepta')
      create :subfamily, name: create(:name, name: 'Lepte')

      results = Taxa::Search.find_name 'Lept', 'beginning_with'
      expect(results.map(&:name).map(&:to_s)).to eq ['Lepta', 'Lepte', 'Lepti']
    end

    describe "Finding full species name" do
      it "searches for full species names" do
        results = Taxa::Search.find_name 'Monoceros rufa '
        expect(results.first).to eq @rufa
      end

      it "searches for whole names, even when using beginning with, even with trailing space" do
        results = Taxa::Search.find_name 'Monoceros rufa ', 'beginning_with'
        expect(results.first).to eq @rufa
      end

      it "searches for partial species names" do
        results = Taxa::Search.find_name 'Monoceros ruf', 'beginning_with'
        expect(results.first).to eq @rufa
      end
    end
  end
end
