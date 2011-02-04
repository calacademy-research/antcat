require 'spec_helper'

describe Taxon do

  it "should have a name" do
    taxon = Taxon.create! :name => 'Cerapachynae', :status => 'valid'
    taxon.name.should == 'Cerapachynae'
  end

  it "should not be invalid or unavailable" do
    taxon = Taxon.create! :name => 'Cerapachynae', :status => 'valid'
    taxon.should_not be_invalid
    taxon.should_not be_unavailable
  end

  describe "import" do
    it "should delete existing taxa" do
      Subfamily.create! :name => 'Cerapachynae'
      Taxon.import {|proc|}
      Taxon.count.should be_zero
    end

    it "should create each part of the hierarchy" do
      Taxon.import do |proc|
        proc.call :genus => 'genus', :subfamily => 'subfamily', :tribe => 'tribe'
      end

      subfamily = Subfamily.find_by_name('subfamily')
      subfamily.should_not be_nil

      tribe = Tribe.find_by_name('tribe')
      tribe.should_not be_nil
      tribe.parent.should == subfamily

      genus = Genus.find_by_name('genus')
      genus.should_not be_nil
      genus.parent.should == tribe
    end
    
    it "should be able to skip tribe" do
      Taxon.import do |proc|
        proc.call :genus => 'genus', :subfamily => 'subfamily', :tribe => ''
      end

      subfamily = Subfamily.find_by_name('subfamily')
      genus = Genus.find_by_name('genus')
      genus.parent.should == subfamily
    end

    it "should save the validity and availability of the genus" do
      Taxon.import do |proc|
        proc.call :genus => 'genus', :subfamily => 'subfamily', :tribe => '', :available => true, :is_valid => false
      end
      genus = Genus.find_by_name 'genus'
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
