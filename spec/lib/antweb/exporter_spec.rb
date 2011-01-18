require 'spec_helper'

describe Antweb::Exporter do
  it "should be able to be created" do
    Antweb::Taxonomy.create! :name => 'genus', :subfamily => 'subfamily', :tribe => 'tribe', :available => true, :is_valid => false

    Antweb::Exporter.export

    subfamily = Subfamily.find_by_name('subfamily')
    subfamily.should_not be_nil

    tribe = Taxon.find_by_name('tribe')
    tribe.should_not be_nil
    tribe.parent.should == subfamily

    genus = Taxon.find_by_name('genus')
    genus.should_not be_nil
    genus.parent.should == tribe
    genus.should be_available
    genus.should_not be_is_valid
  end
end
