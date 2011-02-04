require 'spec_helper'

describe Tribe do

  it "should have a subfamily" do
    subfamily = Subfamily.create! :name => 'Myrmicinae'
    Tribe.create! :name => 'Attini', :subfamily => subfamily
    Tribe.find_by_name('Attini').subfamily.should == subfamily
  end

  it "should have genera, which are its children" do
    attini = Tribe.create! :name => 'Attini'
    Genus.create! :name => 'Acromyrmex', :tribe => attini
    Genus.create! :name => 'Atta', :tribe => attini
    attini.genera.map(&:name).should =~ ['Atta', 'Acromyrmex']
    attini.children.should == attini.genera
  end

end
