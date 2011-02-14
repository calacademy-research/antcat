require 'spec_helper'

describe Taxon do

  it "should have a name" do
    taxon = Taxon.create! :name => 'Cerapachynae'
    taxon.name.should == 'Cerapachynae'
  end

  it "when without status, should not be invalid" do
    taxon = Taxon.create! :name => 'Cerapachynae'
    taxon.should_not be_invalid
  end

  it "when with blank status, should not be invalid" do
    taxon = Taxon.create! :name => 'Cerapachynae', :status => ''
    taxon.should_not be_invalid
  end

  it "should be able to be unidentifiable" do
    taxon = Taxon.create! :name => 'Cerapachynae'
    taxon.should_not be_unidentifiable
    taxon.update_attribute :status, 'unidentifiable'
    taxon.should be_unidentifiable
    taxon.should be_invalid
  end

  it "should be able to be unavailable" do
    taxon = Taxon.create! :name => 'Cerapachynae'
    taxon.should_not be_unavailable
    taxon.should be_available
    taxon.update_attribute :status, 'unavailable'
    taxon.should be_unavailable
    taxon.should_not be_available
    taxon.should be_invalid
  end

  it "should be able to be a synonym" do
    taxon = Taxon.create! :name => 'Cerapachynae'
    taxon.should_not be_synonym
    taxon.update_attribute :status, 'synonym'
    taxon.should be_synonym
    taxon.should be_invalid
  end

  it "should be able to be a fossil" do
    taxon = Taxon.create! :name => 'Cerapachynae'
    taxon.should_not be_fossil
    taxon.update_attribute :fossil, true
    taxon.should be_fossil
  end

  it "should raise if anyone calls #children directly" do
    lambda {Taxon.new.children}.should raise_error NotImplementedError
  end

  it "should be able to be a synonym of something else" do
    gauromyrmex = Taxon.create! :name => 'Gauromyrmex'
    acalama = Taxon.create! :name => 'Acalama', :status => :synonym, :synonym_of => gauromyrmex
    acalama.reload.synonym_of.should == gauromyrmex
  end

end
