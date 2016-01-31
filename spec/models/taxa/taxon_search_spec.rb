require 'spec_helper'

describe Taxon do

  describe "Find by name" do
    it "should return nil if nothing matches" do
      expect(Taxon.find_by_name('sdfsdf')).to eq(nil)
    end
    it "should return one of the items if there are more than one (bad!)" do
      name = FactoryGirl.create :genus_name, name: 'Monomorium'
      2.times {FactoryGirl.create :genus, name: name}
      expect(Taxon.find_by_name('Monomorium').name.name).to eq('Monomorium')
    end
  end

  describe "Find by epithet" do
    it "should return nil if nothing matches" do
      expect(Taxon.find_by_epithet('sdfsdf')).to be_empty
    end
    it "should return all the items if there is more than one" do
      FactoryGirl.create :species, name: FactoryGirl.create(:species_name, name: 'Monomorium alta', epithet: 'alta')
      FactoryGirl.create :species, name: FactoryGirl.create(:species_name, name: 'Atta alta', epithet: 'alta')
      expect(Taxon.find_by_epithet('alta').map(&:name).map(&:to_s)).to match_array(['Monomorium alta', 'Atta alta'])
    end
  end

  describe "Find an epithet in a genus" do
    it "should return nil if nothing matches" do
      expect(Taxon.find_epithet_in_genus('sdfsdf', create_genus)).to eq(nil)
    end
    it "should return the one item" do
      species = create_species 'Atta serratula'
      expect(Taxon.find_epithet_in_genus('serratula', species.genus)).to eq([species])
    end
    describe "Finding mandatory spelling changes" do
      it "should find -a when asked to find -us" do
        species = create_species 'Atta serratula'
        expect(Taxon.find_epithet_in_genus('serratulus', species.genus)).to eq([species])
      end
    end
  end

  describe "Find name" do
    before do
      FactoryGirl.create :genus, name: FactoryGirl.create(:genus_name, name: 'Monomorium')
      @monoceros = FactoryGirl.create :genus, name: FactoryGirl.create(:genus_name, name: 'Monoceros')
      species_name = FactoryGirl.create(:species_name, name: 'Monoceros rufa', epithet: 'rufa')
      @rufa = FactoryGirl.create :species, genus: @monoceros, name: species_name
    end
    it "should return [] if nothing matches" do
      expect(Taxa::Search.find_name('sdfsdf')).to eq([])
    end
    it "should return an exact match" do
      expect(Taxa::Search.find_name('Monomorium').first.name.to_s).to eq('Monomorium')
    end
    it "should return a prefix match" do
      expect(Taxa::Search.find_name('Monomor', 'beginning with').first.name.to_s).to eq('Monomorium')
    end
    it "should return a substring match" do
      expect(Taxa::Search.find_name('iu', 'containing').first.name.to_s).to eq('Monomorium')
    end
    it "should return multiple matches" do
      results = Taxa::Search.find_name('Mono', 'containing')
      expect(results.size).to eq(2)
    end
    it "should not return anything but subfamilies, tribes, genera, subgenera, species,and subspecies" do
      create_subfamily 'Lepto'
      create_tribe 'Lepto1'
      create_genus 'Lepto2'
      create_subgenus 'Lepto3'
      create_species 'Lepto4'
      create_subspecies 'Lepto5'
      results = Taxa::Search.find_name 'Lepto', 'beginning with'
      expect(results.size).to eq(6)
    end
    it "should sort results by name" do
      FactoryGirl.create :subfamily, name: FactoryGirl.create(:name, name: 'Lepti')
      FactoryGirl.create :subfamily, name: FactoryGirl.create(:name, name: 'Lepta')
      FactoryGirl.create :subfamily, name: FactoryGirl.create(:name, name: 'Lepte')
      results = Taxa::Search.find_name 'Lept', 'beginning with'
      expect(results.map(&:name).map(&:to_s)).to eq(['Lepta', 'Lepte', 'Lepti'])
    end

    describe "Finding full species name" do
      it "should search for full species name" do
        results = Taxa::Search.find_name 'Monoceros rufa '
        expect(results.first).to eq(@rufa)
      end
      it "should search for whole name, even when using beginning with, even with trailing space" do
        results = Taxa::Search.find_name 'Monoceros rufa ', 'beginning with'
        expect(results.first).to eq(@rufa)
      end
      it "should search for partial species name" do
        results = Taxa::Search.find_name 'Monoceros ruf', 'beginning with'
        expect(results.first).to eq(@rufa)
      end
    end
  end

end
