# coding: UTF-8
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
      expect(Taxon.find_name('sdfsdf')).to eq([])
    end
    it "should return an exact match" do
      expect(Taxon.find_name('Monomorium').first.name.to_s).to eq('Monomorium')
    end
    it "should return a prefix match" do
      expect(Taxon.find_name('Monomor', 'beginning with').first.name.to_s).to eq('Monomorium')
    end
    it "should return a substring match" do
      expect(Taxon.find_name('iu', 'containing').first.name.to_s).to eq('Monomorium')
    end
    it "should return multiple matches" do
      results = Taxon.find_name('Mono', 'containing')
      expect(results.size).to eq(2)
    end
    it "should not return anything but subfamilies, tribes, genera, subgenera, species,and subspecies" do
      create_subfamily 'Lepto'
      create_tribe 'Lepto1'
      create_genus 'Lepto2'
      create_subgenus 'Lepto3'
      create_species 'Lepto4'
      create_subspecies 'Lepto5'
      results = Taxon.find_name 'Lepto', 'beginning with'
      expect(results.size).to eq(6)
    end
    it "should sort results by name" do
      FactoryGirl.create :subfamily, name: FactoryGirl.create(:name, name: 'Lepti')
      FactoryGirl.create :subfamily, name: FactoryGirl.create(:name, name: 'Lepta')
      FactoryGirl.create :subfamily, name: FactoryGirl.create(:name, name: 'Lepte')
      results = Taxon.find_name 'Lept', 'beginning with'
      expect(results.map(&:name).map(&:to_s)).to eq(['Lepta', 'Lepte', 'Lepti'])
    end

    describe "Finding full species name" do
      it "should search for full species name" do
        results = Taxon.find_name 'Monoceros rufa '
        expect(results.first).to eq(@rufa)
      end
      it "should search for whole name, even when using beginning with, even with trailing space" do
        results = Taxon.find_name 'Monoceros rufa ', 'beginning with'
        expect(results.first).to eq(@rufa)
      end
      it "should search for partial species name" do
        results = Taxon.find_name 'Monoceros ruf', 'beginning with'
        expect(results.first).to eq(@rufa)
      end
    end
  end

  describe "Finding by name and authorship" do
    before do
      @latreille = FactoryGirl.create(:author_name, name: 'Latreille')
      @reference = FactoryGirl.create :article_reference, author_names: [@latreille], citation_year: '1809', bolton_key_cache: 'Latreille 1809'
      authorship = FactoryGirl.create :citation, reference: @reference
      @protonym = FactoryGirl.create :protonym, authorship: authorship
      @genus = create_genus 'Atta', protonym: @protonym
    end
    it "should find a taxon matching the name and authorship ID" do
      expect(Taxon.find_by_name_and_authorship(@genus.name, [@reference.principal_author_last_name_cache], @reference.year)).to eq(@genus)
    end
    it "should distinguish between homonyms by using the authorship" do
      homonym_reference = FactoryGirl.create :article_reference, author_names: [FactoryGirl.create(:author_name, name: 'Fisher')], citation_year: '2005', bolton_key_cache: 'Fisher 2005'
      homonym_authorship = FactoryGirl.create :citation, reference: homonym_reference
      homonym_protonym = FactoryGirl.create :protonym, authorship: homonym_authorship
      homonym_genus = create_genus 'Atta', protonym: homonym_protonym

      expect(Taxon.find_by_name_and_authorship(homonym_genus.name, ['Latreille'], @reference.year)).to eq(@genus)
    end
    it "should distinguish between ones with same authorship by using the name" do
      other_genus = create_genus 'Dolichoderus', protonym: @protonym
      expect(Taxon.find_by_name_and_authorship(other_genus.name, ['Latreille'], @reference.year)).to eq(other_genus)
    end
    it "should distinguish between ones with same name and authorship by using the page", pending: true do
      pending "rewrite to use a factory instead of a removed importer"
      reference = FactoryGirl.create :article_reference, author_names: [@latreille], citation_year: '1809', bolton_key_cache: 'Latreille 1809'
      genus_100_authorship = FactoryGirl.create :citation, reference: reference, pages: '100'
      genus_200_authorship = FactoryGirl.create :citation, reference: reference, pages: '200'
      genus_100_protonym = FactoryGirl.create :protonym, authorship: genus_100_authorship
      genus_200_protonym = FactoryGirl.create :protonym, authorship: genus_200_authorship
      genus_100 = create_genus 'Dolichoderus', protonym: genus_100_protonym
      genus_200 = create_genus 'Dolichoderus', protonym: genus_200_protonym
      expect(Taxon.find_by_name_and_authorship(Name.import(genus_name: 'Dolichoderus'), ['Latreille'], '1809', '100')).to eq(genus_100)
    end

    describe "Searching for other forms of the epithet(s)", pending: true do
      before do
        @reference = FactoryGirl.create :article_reference, bolton_key_cache: 'Fisher 2005'
      end
      it "should find one form of the species epithet when searching for the other" do
        pending "rewrite to use a factory instead of a removed importer"
        cordatus_name = Name.create! name: 'Philidris cordatus protensa'
        cordatus = FactoryGirl.create :subspecies, name: cordatus_name
        cordatus.protonym.authorship.update_attribute :reference, @reference
        search_name = Name.import genus_name: 'Philidris', species_epithet: 'cordata', subspecies: [{subspecies_epithet: 'protensa'}]
        taxon = Taxon.find_by_name_and_authorship search_name, ['Fisher'], 2005
        expect(taxon.name.name).to eq('Philidris cordatus protensa')
      end
      it "should find the taxon even when two components need changing" do
        pending "rewrite to use a factory instead of a removed importer"
        protensus_name = Name.create! name: 'Philidris cordatus protensus'
        protensus = FactoryGirl.create :subspecies, name: protensus_name
        protensus.protonym.authorship.update_attribute :reference, @reference
        search_name = Name.import genus_name: 'Philidris', species_epithet: 'cordata', subspecies: [{subspecies_epithet: 'protensa'}]
        taxon = Taxon.find_by_name_and_authorship search_name, ['Fisher'], 2005
        expect(taxon.name.name).to eq('Philidris cordatus protensus')
      end
    end
  end
end
