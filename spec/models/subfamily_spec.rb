require 'spec_helper'

describe Subfamily do

  it "should have tribes, which are its children" do
    subfamily = Subfamily.create! :name => 'Myrmicinae'
    Tribe.create! :name => 'Attini', :subfamily => subfamily
    Tribe.create! :name => 'Dacetini', :subfamily => subfamily
    subfamily.tribes.map(&:name).should =~ ['Attini', 'Dacetini']
    subfamily.tribes.should == subfamily.children
  end

  it "should have genera" do
    myrmicinae = Subfamily.create! :name => 'Myrmicinae'
    dacetini = Tribe.create! :name => 'Dacetini', :subfamily => myrmicinae
    Genus.create! :name => 'Atta', :subfamily => myrmicinae, :tribe => Tribe.create!(:name => 'Attini', :subfamily => myrmicinae)
    Genus.create! :name => 'Acanthognathus', :subfamily => myrmicinae, :tribe => Tribe.create!(:name => 'Dacetini', :subfamily => myrmicinae)
    myrmicinae.genera.map(&:name).should =~ ['Atta', 'Acanthognathus']
  end

end
