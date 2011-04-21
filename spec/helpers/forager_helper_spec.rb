require 'spec_helper'

describe ForagerHelper do

  describe 'Grouping index items' do

      it "should just return the items if the number of rows isn't exceeded" do
        a = Factory :species, :name => 'a'
        b = Factory :species, :name => 'b'
        helper.make_index_groups([a,b], 2, 4).should == [
          {:label => 'a', :id => a.id, :css_classes => 'species taxon valid'},
          {:label => 'b', :id => b.id, :css_classes => 'species taxon valid'}]
      end

      it "should sort the items" do
        a = Factory :species, :name => 'a'
        b = Factory :species, :name => 'b'
        helper.make_index_groups([b,a], 2, 4).should == [
          {:label => 'a', :id => a.id, :css_classes => 'species taxon valid'},
          {:label => 'b', :id => b.id, :css_classes => 'species taxon valid'}]
      end

      it "should create groups of items" do
        a = Factory :species, :name => 'a'
        b = Factory :species, :name => 'b'
        c = Factory :species, :name => 'c'
        helper.make_index_groups([a,b,c], 2, 4).should == [
          {:label => 'a-b', :id => a.id, :css_classes => 'species taxon'},
          {:label => 'c', :id => c.id, :css_classes => 'species taxon valid'}]
      end

      it "should abbreviate items" do
        a = Factory :species, :name => 'Acanthomyrmex'
        b = Factory :species, :name => 'Atta'
        c = Factory :species, :name => 'Tetramorium'
        helper.make_index_groups([a,b,c], 2, 4).should == [
          {:label => 'Acan-Atta', :id => a.id, :css_classes => 'species taxon'},
          {:label => 'Tetramorium', :id => c.id, :css_classes => 'species taxon valid'}]
      end

      it "should prepend daggers on single items" do
        a = Factory :species, :name => 'Acanthomyrmex', :fossil => true
        helper.make_index_groups([a], 2, 4).should == [{:label => '&dagger;Acanthomyrmex', :id => a.id, :css_classes => 'species taxon valid'}]
      end

  end
end
