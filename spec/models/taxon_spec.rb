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
    acamatus = Factory :taxon, :name => 'Acamatus', :status => 'homonym', :homonym_resolved_to => neivamyrmex
    acamatus.reload
    acamatus.should be_homonym
    acamatus.homonym_resolved_to.should == neivamyrmex
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

  describe "Full name" do

    it "is just the subfamily name if a subfamily" do
      taxon = Factory :subfamily, :name => 'Dolichoderinae'
      taxon.full_name.should == 'Dolichoderinae'
    end

    it "is the subfamily name and the genus if a genus" do
      taxon = Factory :genus, :name => 'Atta', :subfamily => Factory(:subfamily, :name => 'Dolichoderinae')
      taxon.full_name.should == 'Dolichoderinae <i>Atta</i>'
    end

    it "is the subfamily name, the genus, and the species if a species" do
      taxon = Factory :species, :name => 'emeryi', :genus => Factory(:genus, :name => 'Atta', :subfamily => Factory(:subfamily, :name => 'Dolichoderinae'))
      taxon.full_name.should == 'Dolichoderinae <i>Atta emeryi</i>'
    end

    it "is the subfamily name, the genus, the species, and the subspecies if a subspecies" do
      taxon = Factory :subspecies, :name => 'biggus', :species => Factory(:species, :name => 'emeryi', :genus => Factory(:genus, :name => 'Atta', :subfamily => Factory(:subfamily, :name => 'Dolichoderinae')))
      taxon.full_name.should == 'Dolichoderinae <i>Atta emeryi biggus</i>'
    end

  end

  describe "Find name" do
    before do
      Factory :genus, :name => 'Monomorium'
      Factory :genus, :name => 'Monoceros'
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

    it "should not return anything but subfamilies, genera and tribes" do
      Factory :subfamily, :name => 'Lepto'
      Factory :tribe, :name => 'Lepto'
      Factory :genus, :name => 'Lepto'
      Factory :subgenus, :name => 'Lepto'
      Factory :species, :name => 'Lepto'
      Factory :subspecies, :name => 'Lepto'
      results = Taxon.find_name 'Lepto'
      results.size.should == 3
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

    it "should not think it's a synonym of something when it's not" do
      senior_synonym = Factory :genus
      junior_synonym = Factory :genus, :synonym_of => senior_synonym, :status => 'synonym'
      junior_synonym.should be_synonym_of senior_synonym
    end

  end
end
