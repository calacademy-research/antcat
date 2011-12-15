# coding: UTF-8
require 'spec_helper'

describe Taxon do

  it "should require a name" do
    Factory.build(:taxon).should_not be_valid
    taxon = Factory :taxon, :name => 'Cerapachynae'
    taxon.name.should == 'Cerapachynae'
    taxon.should be_valid
  end

  it "should be (Rails) valid with a nil status" do
    Taxon.new(:name => 'Cerapachynae').should be_valid
    Taxon.new(:name => 'Cerapachynae', :status => 'valid').should be_valid
  end

  it "when status 'valid', should not be invalid" do
    taxon = Factory :taxon, :name => 'Cerapachynae'
    taxon.should_not be_invalid
  end

  it "should be able to be unidentifiable" do
    taxon = Factory :taxon, :name => 'Cerapachynae'
    taxon.should_not be_unidentifiable
    taxon.update_attribute :status, 'unidentifiable'
    taxon.should be_unidentifiable
    taxon.should be_invalid
  end

  it "should be able to be unavailable" do
    taxon = Factory :taxon, :name => 'Cerapachynae'
    taxon.should_not be_unavailable
    taxon.should be_available
    taxon.update_attribute :status, 'unavailable'
    taxon.should be_unavailable
    taxon.should_not be_available
    taxon.should be_invalid
  end

  it "should be able to be a synonym" do
    taxon = Factory :taxon, :name => 'Cerapachynae'
    taxon.should_not be_synonym
    taxon.update_attribute :status, 'synonym'
    taxon.should be_synonym
    taxon.should be_invalid
  end

  it "should be able to be a fossil" do
    taxon = Factory :taxon, :name => 'Cerapachynae'
    taxon.should_not be_fossil
    taxon.fossil.should == false
    taxon.update_attribute :fossil, true
    taxon.should be_fossil
  end

  it "should raise if anyone calls #children directly" do
    lambda {Taxon.new.children}.should raise_error NotImplementedError
  end

  it "should be able to be a synonym of something else" do
    gauromyrmex = Factory :taxon, :name => 'Gauromyrmex'
    acalama = Factory :taxon, :name => 'Acalama', :status => 'synonym', :synonym_of => gauromyrmex
    acalama.reload
    acalama.should be_synonym
    acalama.reload.synonym_of.should == gauromyrmex
  end

  it "should be able to be a homonym of something else" do
    neivamyrmex = Factory :taxon, :name => 'Neivamyrmex'
    acamatus = Factory :taxon, :name => 'Acamatus', :status => 'homonym', :homonym_replaced_by => neivamyrmex
    acamatus.reload
    acamatus.should be_homonym
    acamatus.homonym_replaced_by.should == neivamyrmex
  end

  it "should be able to have an incertae_sedis_in" do
    myanmyrma = Factory :taxon, :name => 'Myanmyrma', :incertae_sedis_in => 'family'
    myanmyrma.reload
    myanmyrma.incertae_sedis_in.should == 'family'
    myanmyrma.should_not be_invalid
  end

  it "should be able to store tons of text in taxonomic history" do
    camponotus = Factory :taxon, :name => 'Camponotus', :taxonomic_history => '1234' * 100_000
    camponotus.reload.taxonomic_history.size.should == 4 * 100_000
  end

  describe "Current valid name" do

    it "if it's not a synonym: it's just the name" do
      taxon = Taxon.create! :name => 'Name'
      taxon.current_valid_name.should == 'Name'
    end

    it "if it is a synonym: the name of the target" do
      target = Taxon.create! :name => 'Target'
      taxon = Taxon.create! :name => 'Taxon', :status => 'synonym', :synonym_of => target
      taxon.current_valid_name.should == 'Target'
    end

    it "if it is a synonym of a synonym: the name of the target's target" do
      target_target = Taxon.create! :name => 'Target_Target'
      target = Taxon.create! :name => 'Target', :status => 'synonym', :synonym_of => target_target
      taxon = Taxon.create! :name => 'Taxon', :status => 'synonym', :synonym_of => target
      taxon.current_valid_name.should == 'Target_Target'
    end

  end

  describe "Find name" do
    before do
      Factory :genus, :name => 'Monomorium'
      @monoceros = Factory :genus, :name => 'Monoceros'
      @rufa = Factory :species, :name => 'rufa', :genus => @monoceros
    end

    it "should return [] if nothing matches" do
      Taxon.find_name('sdfsdf').should == []
    end

    it "should return an exact match" do
      Taxon.find_name('Monomorium').first.name.should == 'Monomorium'
    end

    it "should return a prefix match" do
      Taxon.find_name('Monomor', 'beginning with').first.name.should == 'Monomorium'
    end

    it "should return a substring match" do
      Taxon.find_name('iu', 'containing').first.name.should == 'Monomorium'
    end

    it "should return multiple matches" do
      results = Taxon.find_name('Mono', 'containing')
      results.size.should == 2
    end

    it "should not return anything but subfamilies, tribes, genera and species" do
      Factory :subfamily, :name => 'Lepto'
      Factory :tribe, :name => 'Lepto'
      Factory :genus, :name => 'Lepto'
      Factory :subgenus, :name => 'Lepto'
      Factory :species, :name => 'Lepto'
      Factory :subspecies, :name => 'Lepto'
      results = Taxon.find_name 'Lepto'
      results.size.should == 4
    end

    it "should sort results by name" do
      Factory :subfamily, :name => 'Lepti'
      Factory :subfamily, :name => 'Lepta'
      Factory :subfamily, :name => 'Lepte'
      results = Taxon.find_name 'Lept', 'beginning with'
      results.map(&:name).should == ['Lepta', 'Lepte', 'Lepti']
    end

    describe "Finding full species name" do
      it "should search for full species name" do
        results = Taxon.find_name 'Monoceros rufa'
        results.first.should == @rufa
      end

      it "should search for partial species name" do
        results = Taxon.find_name 'Monoceros ruf', 'beginning with'
        results.first.should == @rufa
      end
    end

  end

  describe ".rank" do

    it "should return a lowercase version" do
      Factory(:subfamily).rank.should == 'subfamily'
    end

  end

  describe "being a synonym of" do

    it "should not think it's a synonym of something when it's not" do
      genus = Factory :genus
      another_genus = Factory :genus
      genus.should_not be_synonym_of another_genus
    end

    it "should think it's a synonym of something when it is" do
      senior_synonym = Factory :genus
      junior_synonym = Factory :genus, :synonym_of => senior_synonym, :status => 'synonym'
      junior_synonym.should be_synonym_of senior_synonym
    end

  end

  describe "being a homonym replaced by something" do

    it "should not think it's a homonym replaced by something when it's not" do
      genus = Factory :genus
      another_genus = Factory :genus
      genus.should_not be_homonym_replaced_by another_genus
      genus.homonym_replaced.should be_nil
    end

    it "should think it's a homonym replaced by something when it is" do
      replacement = Factory :genus
      homonym = Factory :genus, :homonym_replaced_by => replacement, :status => 'homonym'
      homonym.should be_homonym_replaced_by replacement
      replacement.homonym_replaced.should == homonym
    end

  end

  describe "the 'valid' scope" do
    it "should only include valid taxa" do
      subfamily = Factory :subfamily
      replacement = Factory :genus, :subfamily => subfamily
      homonym = Factory :genus, :homonym_replaced_by => replacement, :status => 'homonym', :subfamily => subfamily
      synonym = Factory :genus, :synonym_of => replacement, :status => 'synonym', :subfamily => subfamily
      subfamily.genera.valid.should == [replacement]
    end
  end

  describe "the 'extant' scope" do
    it "should only include extant taxa" do
      subfamily = Factory :subfamily
      extant_genus = Factory :genus, :subfamily => subfamily
      Factory :genus, :subfamily => subfamily, :fossil => true
      subfamily.genera.extant.should == [extant_genus]
    end
  end

  describe "ordered by name" do
    it "should order by name" do
      zymacros = Factory :subfamily, :name => 'Zymacros'
      atta = Factory :subfamily, :name => 'Atta'
      Taxon.ordered_by_name.should == [atta, zymacros]
    end
  end

  describe "Convert asterisks to daggers" do
    it "should convert an asterisk to a dagger" do
      taxon = Factory :subfamily
      taxon.taxonomic_history = '*'
      taxon.convert_asterisks_to_daggers!
      taxon.taxonomic_history.should == '&dagger;'
      taxon.reload.taxonomic_history.should == '&dagger;'
    end
    it "work OK if taxonomic history is nil" do
      taxon = Factory :subfamily,  :taxonomic_history => nil
      taxon.convert_asterisks_to_daggers!
      taxon.taxonomic_history.should be_nil
      taxon.reload.taxonomic_history.should be_nil
    end
  end

  describe "Protonym" do
    it "should have a protonym" do
      taxon = Family.create! :name => 'Formicidae'
      taxon.protonym.should be_nil
      taxon.build_protonym :name => 'Formicariae'
    end
  end

end
