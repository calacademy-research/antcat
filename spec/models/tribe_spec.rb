require 'spec_helper'

describe Tribe do

  it "should have a subfamily" do
    subfamily = Subfamily.create! :name => 'Myrmicinae', :status => 'valid'
    Tribe.create! :name => 'Attini', :subfamily => subfamily, :status => 'valid'
    Tribe.find_by_name('Attini').subfamily.should == subfamily
  end

  it "should have genera, which are its children" do
    attini = Tribe.create! :name => 'Attini', :status => 'valid'
    Genus.create! :name => 'Acromyrmex', :tribe => attini, :status => 'valid'
    Genus.create! :name => 'Atta', :tribe => attini, :status => 'valid'
    attini.genera.map(&:name).should =~ ['Atta', 'Acromyrmex']
    attini.children.should == attini.genera
  end

end
