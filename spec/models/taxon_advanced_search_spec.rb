# coding: UTF-8
require 'spec_helper'

describe Taxon do

  describe "Find by name" do
    it "should return nil if nothing matches" do
      Taxon.find_by_name('sdfsdf').should == nil
    end
    it "should return one of the items if there are more than one (bad!)" do
      name = FactoryGirl.create :genus_name, name: 'Monomorium'
      2.times {FactoryGirl.create :genus, name: name}
      Taxon.find_by_name('Monomorium').name.name.should == 'Monomorium'
    end
  end

  describe "Find by epithet" do
    it "should return nil if nothing matches" do
      Taxon.find_by_epithet('sdfsdf').should be_empty
    end
    it "should return all the items if there is more than one" do
      FactoryGirl.create :species, name: FactoryGirl.create(:species_name, name: 'Monomorium alta', epithet: 'alta')
      FactoryGirl.create :species, name: FactoryGirl.create(:species_name, name: 'Atta alta', epithet: 'alta')
      Taxon.find_by_epithet('alta').map(&:name).map(&:to_s).should =~ ['Monomorium alta', 'Atta alta']
    end
  end

  describe "Find an epithet in a genus" do
    it "should return nil if nothing matches" do
      Taxon.find_epithet_in_genus('sdfsdf', create_genus).should == nil
    end
    it "should return the one item" do
      species = create_species 'Atta serratula'
      Taxon.find_epithet_in_genus('serratula', species.genus).should == [species]
    end
    describe "Finding mandatory spelling changes" do
      it "should find -a when asked to find -us" do
        species = create_species 'Atta serratula'
        Taxon.find_epithet_in_genus('serratulus', species.genus).should == [species]
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
      Taxon.find_name('sdfsdf').should == []
    end
    it "should return an exact match" do
      Taxon.find_name('Monomorium').first.name.to_s.should == 'Monomorium'
    end
    it "should return a prefix match" do
      Taxon.find_name('Monomor', 'beginning with').first.name.to_s.should == 'Monomorium'
    end
    it "should return a substring match" do
      Taxon.find_name('iu', 'containing').first.name.to_s.should == 'Monomorium'
    end
    it "should return multiple matches" do
      results = Taxon.find_name('Mono', 'containing')
      results.size.should == 2
    end
    it "should not return anything but subfamilies, tribes, genera, subgenera, species,and subspecies" do
      create_subfamily 'Lepto'
      create_tribe 'Lepto1'
      create_genus 'Lepto2'
      create_subgenus 'Lepto3'
      create_species 'Lepto4'
      create_subspecies 'Lepto5'
      results = Taxon.find_name 'Lepto', 'beginning with'
      results.size.should == 6
    end
    it "should sort results by name" do
      FactoryGirl.create :subfamily, name: FactoryGirl.create(:name, name: 'Lepti')
      FactoryGirl.create :subfamily, name: FactoryGirl.create(:name, name: 'Lepta')
      FactoryGirl.create :subfamily, name: FactoryGirl.create(:name, name: 'Lepte')
      results = Taxon.find_name 'Lept', 'beginning with'
      results.map(&:name).map(&:to_s).should == ['Lepta', 'Lepte', 'Lepti']
    end

    describe "Finding full species name" do
      it "should search for full species name" do
        results = Taxon.find_name 'Monoceros rufa '
        results.first.should == @rufa
      end
      it "should search for whole name, even when using beginning with, even with trailing space" do
        results = Taxon.find_name 'Monoceros rufa ', 'beginning with'
        results.first.should == @rufa
      end
      it "should search for partial species name" do
        results = Taxon.find_name 'Monoceros ruf', 'beginning with'
        results.first.should == @rufa
      end
    end
  end

  describe "Finding by name and authorship" do
    before do
      @reference = FactoryGirl.create :article_reference, author_names: [FactoryGirl.create(:author_name, name: 'Latreille')], citation_year: '1809', bolton_key_cache: 'Latreille 1809'
      authorship = FactoryGirl.create :citation, reference: @reference
      @protonym = FactoryGirl.create :protonym, authorship: authorship
      @genus = create_genus 'Atta', protonym: @protonym
    end
    it "should find a taxon matching the name and authorship ID" do
      Taxon.find_by_name_and_authorship(@genus.name, [@reference.principal_author_last_name_cache], @reference.year).should == @genus
    end
    it "should distinguish between homonyms by using the authorship" do
      homonym_reference = FactoryGirl.create :article_reference, author_names: [FactoryGirl.create(:author_name, name: 'Fisher')], citation_year: '2005', bolton_key_cache: 'Fisher 2005'
      homonym_authorship = FactoryGirl.create :citation, reference: homonym_reference
      homonym_protonym = FactoryGirl.create :protonym, authorship: homonym_authorship
      homonym_genus = create_genus 'Atta', protonym: homonym_protonym

      Taxon.find_by_name_and_authorship(homonym_genus.name, ['Latreille'], @reference.year).should == @genus
    end
    it "should distinguish between ones with same authorship by using the name" do
      other_genus = create_genus 'Dolichoderus', protonym: @protonym
      Taxon.find_by_name_and_authorship(other_genus.name, ['Latreille'], @reference.year).should == other_genus
    end
    it "should distinguish between ones with same name and authorship by using the page" do
      reference = FactoryGirl.create :article_reference, author_names: [FactoryGirl.create(:author_name, name: 'Latreille')], citation_year: '1809', bolton_key_cache: 'Latreille 1809'
      genus_100_authorship = FactoryGirl.create :citation, reference: reference, pages: '100'
      genus_200_authorship = FactoryGirl.create :citation, reference: reference, pages: '200'
      genus_100_protonym = FactoryGirl.create :protonym, authorship: genus_100_authorship
      genus_200_protonym = FactoryGirl.create :protonym, authorship: genus_200_authorship
      genus_100 = create_genus 'Dolichoderus', protonym: genus_100_protonym
      genus_200 = create_genus 'Dolichoderus', protonym: genus_200_protonym
      Taxon.find_by_name_and_authorship(Name.import(genus_name: 'Dolichoderus'), ['Latreille'], '1809', '100').should == genus_100
    end

    describe "Searching for other forms of the epithet(s)" do
      before do
        @reference = FactoryGirl.create :article_reference, bolton_key_cache: 'Fisher 2005'
      end
      it "should find one form of the species epithet when searching for the other" do
        cordatus_name = Name.create! name: 'Philidris cordatus protensa'
        cordatus = FactoryGirl.create :subspecies, name: cordatus_name
        cordatus.protonym.authorship.update_attribute :reference, @reference
        search_name = Name.import genus_name: 'Philidris', species_epithet: 'cordata', subspecies: [{subspecies_epithet: 'protensa'}]
        taxon = Taxon.find_by_name_and_authorship search_name, ['Fisher'], 2005
        taxon.name.name.should == 'Philidris cordatus protensa'
      end
      it "should find the taxon even when two components need changing" do
        protensus_name = Name.create! name: 'Philidris cordatus protensus'
        protensus = FactoryGirl.create :subspecies, name: protensus_name
        protensus.protonym.authorship.update_attribute :reference, @reference
        search_name = Name.import genus_name: 'Philidris', species_epithet: 'cordata', subspecies: [{subspecies_epithet: 'protensa'}]
        taxon = Taxon.find_by_name_and_authorship search_name, ['Fisher'], 2005
        taxon.name.name.should == 'Philidris cordatus protensus'
      end
    end
  end

  describe "Advanced search" do
    describe "Rank first described in given year" do
      it "should return the one match" do
        reference1977 = reference_factory author_name: 'Bolton', citation_year: '1977'
        reference1988 = reference_factory author_name: 'Fisher', citation_year: '1988'
        atta = create_genus
        atta.protonym.authorship.update_attributes! reference: reference1977
        betta = create_genus
        betta.protonym.authorship.update_attributes! reference: reference1977
        gamma = create_genus
        gamma.protonym.authorship.update_attributes! reference: reference1988
        Taxon.advanced_search('Genus', 1977, true).map(&:id).should =~ [atta.id, betta.id]
      end
      it "should honor the validity flag" do
        reference1977 = reference_factory author_name: 'Bolton', citation_year: '1977'
        reference1988 = reference_factory author_name: 'Fisher', citation_year: '1988'
        atta = create_genus
        atta.protonym.authorship.update_attributes! reference: reference1977
        betta = create_genus
        betta.protonym.authorship.update_attributes! reference: reference1977
        gamma = create_genus
        gamma.protonym.authorship.update_attributes! reference: reference1988
        delta = create_genus
        delta.protonym.authorship.update_attributes! reference: reference1977
        delta.update_attributes! status: 'synonym'
        Taxon.advanced_search('Genus', 1977, true).map(&:id).should =~ [atta.id, betta.id]
      end

      it "should return all regardless of validity if that flag is false" do
        reference1977 = reference_factory author_name: 'Bolton', citation_year: '1977'
        atta = create_genus
        atta.protonym.authorship.update_attributes! reference: reference1977
        atta.update_attributes! status: 'synonym'
        Taxon.advanced_search('Genus', 1977, false).map(&:id).should =~ [atta.id]
      end
    end
  end
end
