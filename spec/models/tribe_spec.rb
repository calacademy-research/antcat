require 'spec_helper'

describe Tribe do

  it "should have a subfamily" do
    subfamily = Factory :subfamily, :name => 'Myrmicinae'
    Factory :tribe, :name => 'Attini', :subfamily => subfamily
    Tribe.find_by_name('Attini').subfamily.should == subfamily
  end

  it "should have genera, which are its children" do
    attini = Factory :tribe, :name => 'Attini'
    Factory :genus, :name => 'Acromyrmex', :tribe => attini
    Factory :genus, :name => 'Atta', :tribe => attini
    attini.genera.map(&:name).should =~ ['Atta', 'Acromyrmex']
    attini.children.should == attini.genera
  end

  it "should have as its full name, the subfamily + its name" do
    taxon = Factory :tribe, :name => 'Attini', :subfamily => Factory(:subfamily, :name => 'Myrmicinae')
    taxon.full_name.should == 'Myrmicinae Attini'
  end

  describe "Siblings" do

    it "should return itself and its subfamily's other tribes" do
      Factory :tribe
      subfamily = Factory :subfamily
      tribe = Factory :tribe, :subfamily => subfamily
      another_tribe = Factory :tribe, :subfamily => subfamily
      tribe.siblings.should =~ [tribe, another_tribe]
    end

  end

  describe "Statistics" do
    it "should have none" do
      Factory(:tribe).statistics.should be_nil
    end
  end

end
