require 'spec_helper'

describe Subfamily do
  it "should have these fields" do
    subfamily = Subfamily.create! :name => 'Cerapachynae', :is_valid => true, :available => true
    subfamily.parent = Family.create! :name => 'Formicidae'
    subfamily.save!
    subfamily.children << Tribe.create!(:name => 'Attini')
    subfamily.children << Genus.create!(:name => 'Formica')

    subfamily.parent.should have(1).children
    subfamily.parent.should be_kind_of Family
    subfamily.should have(2).children
    subfamily.name.should == 'Cerapachynae'
    subfamily.should be_kind_of Subfamily
    subfamily.should be_is_valid
    subfamily.should be_available
  end
end
