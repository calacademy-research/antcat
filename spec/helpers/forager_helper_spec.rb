require 'spec_helper'

describe ForagerHelper do

  describe 'Grouping index items' do

      it "should just return the items if the number of rows isn't exceeded" do
        a = Factory :species, :name => 'a'
        b = Factory :species, :name => 'b'
        helper.make_index_groups([a,b], 2, 4).should == [['a', a.id], ['b', b.id]]
      end

      it "should sort the items" do
        a = Factory :species, :name => 'a'
        b = Factory :species, :name => 'b'
        helper.make_index_groups([b,a], 2, 4).should == [['a', a.id], ['b', b.id]]
      end

      it "should create groups of items" do
        a = Factory :species, :name => 'a'
        b = Factory :species, :name => 'b'
        c = Factory :species, :name => 'c'
        helper.make_index_groups([a,b,c], 2, 4).should == [['a-b', a.id], ['c', c.id]]
      end

      it "should abbreviate items" do
        a = Factory :species, :name => 'Acanthomyrmex'
        b = Factory :species, :name => 'Atta'
        c = Factory :species, :name => 'Tetramorium'
        helper.make_index_groups([a,b,c], 2, 4).should == [['Acan-Atta', a.id], ['Tetramorium', c.id]]
      end

  end
end
