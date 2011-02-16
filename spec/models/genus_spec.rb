require 'spec_helper'

describe Genus do

  it "should have a tribe" do
    attini = Tribe.create! :name => 'Attini', :subfamily => Subfamily.create!(:name => 'Myrmicinae', :status => 'valid'), :status => 'valid'
    Genus.create! :name => 'Atta', :tribe => attini, :status => 'valid'
    Genus.find_by_name('Atta').tribe.should == attini
  end

  it "should have species, which are its children" do
    atta = Genus.create! :name => 'Atta', :status => 'valid'
    Species.create! :name => 'robusta', :genus => atta, :status => 'valid'
    Species.create! :name => 'saltensis', :genus => atta, :status => 'valid'
    atta = Genus.find_by_name('Atta')
    atta.species.map(&:name).should =~ ['robusta', 'saltensis']
    atta.children.should == atta.species
  end

end
