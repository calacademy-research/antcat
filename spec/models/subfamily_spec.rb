require 'spec_helper'

describe Subfamily do

  it "should have tribes, which are its children" do
    subfamily = Subfamily.create! :name => 'Myrmicinae', :status => 'valid'
    Tribe.create! :name => 'Attini', :subfamily => subfamily, :status => 'valid'
    Tribe.create! :name => 'Dacetini', :subfamily => subfamily, :status => 'valid'
    subfamily.tribes.map(&:name).should =~ ['Attini', 'Dacetini']
    subfamily.tribes.should == subfamily.children
  end

  it "should have genera" do
    myrmicinae = Subfamily.create! :name => 'Myrmicinae', :status => 'valid'
    dacetini = Tribe.create! :name => 'Dacetini', :subfamily => myrmicinae, :status => 'valid'
    Genus.create! :name => 'Atta', :subfamily => myrmicinae, :tribe => Tribe.create!(:name => 'Attini', :subfamily => myrmicinae, :status => 'valid'), :status => 'valid'
    Genus.create! :name => 'Acanthognathus', :subfamily => myrmicinae, :tribe => Tribe.create!(:name => 'Dacetini', :subfamily => myrmicinae, :status => 'valid'), :status => 'valid'
    myrmicinae.genera.map(&:name).should =~ ['Atta', 'Acanthognathus']
  end

end
