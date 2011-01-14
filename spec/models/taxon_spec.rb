require 'spec_helper'

describe Taxon do
  it "should have these fields" do
    taxon = Taxon.create! :name => 'Cerapachynae', :rank => 'subfamily', :is_valid => true, :available => true
    taxon.create_parent :name => 'Formicidae', :rank => 'family'
    taxon.save!
    taxon.children.create :name => 'Attini', :rank => 'tribe'
    taxon.children.create :name => 'Formica', :rank => 'genus'

    taxon.parent.should have(1).children
    taxon.should have(2).children
    taxon.name.should == 'Cerapachynae'
    taxon.rank.should == 'subfamily'
    taxon.should be_is_valid
    taxon.should be_available
  end

  describe "import" do
    it "should delete existing taxa" do
      Taxon.create! :name => 'Cerapachynae', :rank => 'subfamily'
      Taxon.import {|proc|}
      Taxon.count.should be_zero
    end

    it "should create each part of the hierarchy" do
      Taxon.import do |proc|
        proc.call :genus => 'genus', :subfamily => 'subfamily', :tribe => 'tribe'
      end

      subfamily = Taxon.find_by_name('subfamily')
      subfamily.rank.should == 'subfamily'

      tribe = Taxon.find_by_name('tribe')
      tribe.rank.should == 'tribe'
      tribe.parent.should == subfamily

      genus = Taxon.find_by_name('genus')
      genus.rank.should == 'genus'
      genus.parent.should == tribe
    end
    
    it "should create be able to skip tribe" do
      Taxon.import do |proc|
        proc.call :genus => 'genus', :subfamily => 'subfamily', :tribe => ''
      end

      subfamily = Taxon.find_by_name('subfamily')
      subfamily.rank.should == 'subfamily'

      genus = Taxon.find_by_name('genus')
      genus.rank.should == 'genus'
      genus.parent.should == subfamily
    end

    it "should save the validity and availability of the genus" do
      Taxon.import do |proc|
        proc.call :genus => 'genus', :subfamily => 'subfamily', :tribe => '', :available => true, :is_valid => false
      end
      genus = Taxon.find_by_name 'genus'
      genus.should be_available
      genus.should_not be_is_valid
    end

    it "should only create each taxon once" do
      Taxon.import do |proc|
        proc.call :genus => 'genus', :subfamily => 'subfamily', :tribe => 'tribe'
        proc.call :genus => 'another_genus', :subfamily => 'subfamily', :tribe => 'tribe'
      end
      Taxon.count.should == 4
    end
    
  end
end
